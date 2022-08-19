import { BoundsVelocity } from '../utils/measurement';

type ContextAwareBoundsConstructorArgs = {
  element: DOMRect;
  contextElement: DOMRect;
  parent?: DOMRect;
};

export interface Position {
  left: number;
  top: number;
}
export type Bounds = {
  left: number;
  top: number;
  width: number;
  height: number;
};
export type BoundsDelta = {
  x: number;
  y: number;
  width: number;
  height: number;
};

export default class ContextAwareBounds {
  element: DOMRect;
  context: DOMRect;
  parent: DOMRect | undefined;
  velocity: BoundsVelocity = {
    x: 0,
    y: 0,
    width: 0,
    height: 0,
  };

  constructor({
    element,
    contextElement,
    parent,
  }: ContextAwareBoundsConstructorArgs) {
    this.element = element;
    this.context = contextElement;
    this.parent = parent;
  }

  get relativeToContext(): DOMRect {
    let { element, context } = this;
    return new DOMRect(
      element.left - context.left,
      element.top - context.top,
      element.width,
      element.height
    );
  }

  get relativeToParent(): DOMRect {
    let { element, parent } = this;

    if (!parent) {
      // TODO: in the case of an interrupted orphan, there's no defined parent (in the sprite tree).
      //  The below is a hotfix to send back the correct bounds for the situation. We need a better solution.
      return this.relativeToContext;
    }

    return new DOMRect(
      element.left - parent.left,
      element.top - parent.top,
      element.width,
      element.height
    );
  }

  relativeToPosition({ left, top }: Position): DOMRect {
    let { element } = this;
    return new DOMRect(
      this.element.left - left,
      this.element.top - top,
      element.width,
      element.height
    );
  }
}
