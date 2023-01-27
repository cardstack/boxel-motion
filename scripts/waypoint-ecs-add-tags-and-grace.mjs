// This is copied from cardstack/cardstack with the addition of --health-check-grace-period-seconds

import hcl from 'hcl2-parser';
import fs from 'fs';
import { execSync } from 'child_process';

function execute(command, options = {}) {
  return execSync(command, options).toString().trim();
}

function getAppConfig(waypointConfigFilePath, appName) {
  const waypointHcl = fs.readFileSync(waypointConfigFilePath, 'utf8');
  const waypointConfig = hcl.parseToObject(waypointHcl)[0];
  const waypointApp = waypointConfig.app[appName][0];
  const cluster = waypointApp.deploy[0].use['aws-ecs'][0].cluster;

  return { cluster };
}

function getAppNameFromServiceArn(serviceArn) {
  const arnPattern = /^.*\/(.*)-[^-]*$/;
  const matches = serviceArn.match(arnPattern);
  return matches && matches.length > 1 ? matches[1] : '';
}

function getServices(cluster, appName) {
  let serviceArns = [];
  let nextToken = null;
  do {
    const startingTokenArg = nextToken ? `--starting-token ${nextToken}` : '';
    const responseJson = execute(`aws ecs list-services --cluster ${cluster} ${startingTokenArg}`);
    const response = JSON.parse(responseJson);
    const filtered = response.serviceArns.filter((arn) => getAppNameFromServiceArn(arn) === appName);
    serviceArns = serviceArns.concat(filtered);
    nextToken = response.nextToken;
  } while (nextToken);

  let services = [];
  for (let i = 0; i < serviceArns.length; i += 10) {
    const slicedServiceNames = serviceArns.slice(i, i + 10 > serviceArns.length ? serviceArns.length : i + 10);

    const responseJson = execute(
      `aws ecs describe-services --include TAGS --cluster ${cluster} --services ${slicedServiceNames.join(' ')}`
    );
    const response = JSON.parse(responseJson);
    services = services.concat(response.services);
  }

  services.sort((a, b) => {
    if (a.createdAt < b.createdAt) {
      return 1;
    } else if (a.createdAt > b.createdAt) {
      return -1;
    } else {
      return 0;
    }
  });

  return services;
}

function isTagged(service, tags) {
  if (!service.tags) return false;

  let existingTags = {};
  service.tags.forEach((tag) => {
    existingTags[tag.key] = tag.value;
  });

  for (const key in tags) {
    if (existingTags[key] !== tags[key]) return false;
  }

  return service.enableECSManagedTags && service.propagateTags === 'SERVICE';
}

function tagResourcesAndAddGracePeriodAndVolume(cluster, service, tags) {
  const tagsArgs = Object.entries(tags)
    .map(([key, val]) => `key=${key},value=${val}`)
    .join(' ');

  console.log(`-> Tagging service: ${service.serviceName}`);
  execute(`aws ecs tag-resource --resource-arn ${service.serviceArn} --tags ${tagsArgs}`);

  const taskDefinition = JSON.parse(execute(`aws ecs describe-task-definition --task-definition ${service.taskDefinition}`));
  taskDefinition.taskDefinition.volumes = [
    {
        "name": "doesitexist",
        "efsVolumeConfiguration": {
            "fileSystemId": "fs-07b96c537c8c42381",
            "rootDirectory": "/",
            "transitEncryption": "ENABLED",
            "authorizationConfig": {
                "accessPointId": "fsap-05f6f7e465f171f43",
                "iam": "DISABLED"
            }
        }
    }
  ];

  taskDefinition.taskDefinition.containerDefinitions[0].mountPoints = [{
    containerPath: '/anewpathya',
    sourceVolume: 'doesitexist',
  }];

  console.log('td', taskDefinition);

  delete taskDefinition.taskDefinition.taskDefinitionArn;
  delete taskDefinition.taskDefinition.revision;
  delete taskDefinition.taskDefinition.status;
  delete taskDefinition.taskDefinition.requiresAttributes;
  delete taskDefinition.taskDefinition.compatibilities;
  delete taskDefinition.taskDefinition.registeredAt;
  delete taskDefinition.taskDefinition.registeredBy;

  fs.writeFileSync('tmp.json', JSON.stringify(taskDefinition.taskDefinition, null, 2));

  const family = taskDefinition.taskDefinition.family;
  const registeredTaskDefinition = JSON.parse(execute(
    `aws ecs register-task-definition` +
      ` --family ${family}` +
      ` --cli-input-json file://tmp.json`
  ));

  console.log('rtd', registeredTaskDefinition);

  console.log(`-> Updating service to propagate tags to tasks: ${service.serviceName}`);
  execute(
    `aws ecs update-service` +
      ` --cluster ${cluster}` +
      ` --service ${service.serviceArn}` +
      ` --task-definition ${registeredTaskDefinition.taskDefinition.taskDefinitionArn}` +
      ` --force-new-deployment` +
      ` --health-check-grace-period-seconds 240` +
      ` --enable-ecs-managed-tags` +
      ` --propagate-tags SERVICE`
  );
}

function main() {
  const [appName, ...extraArgs] = process.argv.slice(2);
  const waypointConfigFilePath = extraArgs.length > 0 ? extraArgs[0] : 'waypoint.hcl';

  const config = getAppConfig(waypointConfigFilePath, appName);

  const tags = {
    'waypoint-app': appName,
    'cardstack:application-id': appName,
  };

  console.log('\n» Tagging resources...');
  const services = getServices(config.cluster, appName);
  const latestService = services[0];

  if (!isTagged(latestService, tags)) {
    tagResourcesAndAddGracePeriodAndVolume(config.cluster, latestService, tags);
  }
}

try {
  main();
} catch (err) {
  console.error(err);
}
