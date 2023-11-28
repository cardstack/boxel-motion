import { primitive, Component, serialize, FieldDef } from './card-api';
import { BoxelInput } from '@cardstack/boxel-ui/components';
import { TextInputFilter } from './text-input-filter';

function _serialize(val: bigint): string {
  return val.toString();
}

function deserialize(string: string | null | undefined): bigint | null {
  if (string == null || string === '') {
    return null;
  }
  return BigInt(string);
}

function validate(value: string | null): string | null {
  if (value == null || value === '') {
    return null;
  }

  try {
    BigInt(value);
  } catch (error: any) {
    return 'Invalid big integer';
  }
  return null;
}

class View extends Component<typeof BigIntegerField> {
  <template>
    {{@model}}
  </template>
}

class Edit extends Component<typeof BigIntegerField> {
  <template>
    <BoxelInput
      @value={{this.textInputFilter.asString}}
      @onInput={{this.textInputFilter.onInput}}
      @errorMessage={{this.textInputFilter.errorMessage}}
      @state={{if this.textInputFilter.isInvalid 'invalid' 'none'}}
    />
  </template>

  textInputFilter: TextInputFilter<bigint> = new TextInputFilter(
    () => this.args.model,
    (inputVal) => this.args.set(inputVal),
    deserialize,
    _serialize,
    validate,
  );
}

export default class BigIntegerField extends FieldDef {
  static displayName = 'BigInteger';
  static [primitive]: bigint;
  static [serialize](val: bigint) {
    return _serialize(val);
  }

  static embedded = View;
  static atom = View;
  static edit = Edit;
}
