import {
  Component as BoxelComponent,
  CardDef,
} from 'https://cardstack.com/base/card-api';
import Component from '@glimmer/component';
import StringCard from 'https://cardstack.com/base/string';
import { contains, field } from 'https://cardstack.com/base/card-api';

import lodash from 'https://cdn.jsdelivr.net/npm/lodash@4.17.21/+esm';
import {
  Chessboard,
  FEN,
} from 'https://cdn.jsdelivr.net/npm/cm-chessboard@8.7.3/+esm';

import Modifier from 'ember-modifier';

class ChessboardModifier extends Modifier {
  modify(element: HTMLElement) {
    new Chessboard(element, {
      position: FEN.start,
      style: {
        pieces: {
          file: 'https://cdn.jsdelivr.net/npm/cm-chessboard@8.7.3/assets/pieces/standard.svg',
        },
      },
    });
  }
}

interface Signature {
  Args: {};
}

class ChessboardComponent extends Component<Signature> {
  <template>
    <div id='board' {{ChessboardModifier}}>
    </div>
    <style>
      #board {
        width: 600px;
      }
    </style>
    {{! needs unscoped or global }}
    <style unscoped>
      .cm-chessboard .board.input-enabled .square {
        cursor: pointer;
      }

      .cm-chessboard .coordinates,
      .cm-chessboard .markers-layer,
      .cm-chessboard .pieces-layer,
      .cm-chessboard .markers-top-layer {
        pointer-events: none;
      }

      .cm-chessboard-content .list-inline {
        padding-left: 0;
        list-style: none;
      }

      .cm-chessboard-content .list-inline-item {
        display: inline-block;
      }
      .cm-chessboard-content .list-inline-item:not(:last-child) {
        margin-right: 1rem;
      }

      .cm-chessboard-content .list-inline {
        padding-left: 0;
        list-style: none;
      }

      .cm-chessboard-content .list-inline-item {
        display: inline-block;
      }
      .cm-chessboard-content .list-inline-item:not(:last-child) {
        margin-right: 1rem;
      }

      .cm-chessboard-accessibility.visually-hidden {
        width: 1px;
        height: 1px;
        padding: 0;
        margin: -1px;
        overflow: hidden;
        clip: rect(0, 0, 0, 0);
        white-space: nowrap;
        border: 0;
      }

      .cm-chessboard.default .board .square.white {
        fill: #ecdab9;
      }

      .cm-chessboard.default .board .square.black {
        fill: #c5a076;
      }

      .cm-chessboard.default.border-type-thin .board .border {
        stroke: #c5a076;
        stroke-width: 0.7%;
        fill: #c5a076;
      }

      .cm-chessboard.default.border-type-none .board .border {
        stroke: #c5a076;
        stroke-width: 0;
        fill: #c5a076;
      }

      .cm-chessboard.default.border-type-frame .board .border {
        fill: #ecdab9;
        stroke: none;
      }

      .cm-chessboard.default.border-type-frame .board .border-inner {
        fill: #c5a076;
        stroke: #c5a076;
        stroke-width: 0.7%;
      }

      .cm-chessboard.default .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.default .coordinates .coordinate {
        fill: #b5936d;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.default .coordinates .coordinate.black {
        fill: #eeddbf;
      }
      .cm-chessboard.default .coordinates .coordinate.white {
        fill: #b5936d;
      }

      .cm-chessboard.default-contrast .board .square.white {
        fill: #ecdab9;
      }

      .cm-chessboard.default-contrast .board .square.black {
        fill: #c5a076;
      }

      .cm-chessboard.default-contrast.border-type-thin .board .border {
        stroke: #c5a076;
        stroke-width: 0.7%;
        fill: #c5a076;
      }

      .cm-chessboard.default-contrast.border-type-none .board .border {
        stroke: #c5a076;
        stroke-width: 0;
        fill: #c5a076;
      }

      .cm-chessboard.default-contrast.border-type-frame .board .border {
        fill: #ecdab9;
        stroke: none;
      }

      .cm-chessboard.default-contrast.border-type-frame .board .border-inner {
        fill: #c5a076;
        stroke: #c5a076;
        stroke-width: 0.7%;
      }

      .cm-chessboard.default-contrast .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.default-contrast .coordinates .coordinate {
        fill: #b5936d;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.default-contrast .coordinates .coordinate.black {
        fill: #333;
      }
      .cm-chessboard.default-contrast .coordinates .coordinate.white {
        fill: #333;
      }

      .cm-chessboard.green .board .square.white {
        fill: #e0ddcc;
      }

      .cm-chessboard.green .board .square.black {
        fill: #4c946a;
      }

      .cm-chessboard.green.border-type-thin .board .border {
        stroke: #4c946a;
        stroke-width: 0.7%;
        fill: #4c946a;
      }

      .cm-chessboard.green.border-type-none .board .border {
        stroke: #4c946a;
        stroke-width: 0;
        fill: #4c946a;
      }

      .cm-chessboard.green.border-type-frame .board .border {
        fill: #e0ddcc;
        stroke: none;
      }

      .cm-chessboard.green.border-type-frame .board .border-inner {
        fill: #4c946a;
        stroke: #4c946a;
        stroke-width: 0.7%;
      }

      .cm-chessboard.green .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.green .coordinates .coordinate {
        fill: #468862;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.green .coordinates .coordinate.black {
        fill: #e2e0d0;
      }
      .cm-chessboard.green .coordinates .coordinate.white {
        fill: #468862;
      }

      .cm-chessboard.blue .board .square.white {
        fill: #d8ecfb;
      }

      .cm-chessboard.blue .board .square.black {
        fill: #86afcf;
      }

      .cm-chessboard.blue.border-type-thin .board .border {
        stroke: #86afcf;
        stroke-width: 0.7%;
        fill: #86afcf;
      }

      .cm-chessboard.blue.border-type-none .board .border {
        stroke: #86afcf;
        stroke-width: 0;
        fill: #86afcf;
      }

      .cm-chessboard.blue.border-type-frame .board .border {
        fill: #d8ecfb;
        stroke: none;
      }

      .cm-chessboard.blue.border-type-frame .board .border-inner {
        fill: #86afcf;
        stroke: #86afcf;
        stroke-width: 0.7%;
      }

      .cm-chessboard.blue .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.blue .coordinates .coordinate {
        fill: #7ba1be;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.blue .coordinates .coordinate.black {
        fill: #dbeefb;
      }
      .cm-chessboard.blue .coordinates .coordinate.white {
        fill: #7ba1be;
      }

      .cm-chessboard.chess-club .board .square.white {
        fill: #e6d3b1;
      }

      .cm-chessboard.chess-club .board .square.black {
        fill: #af6b3f;
      }

      .cm-chessboard.chess-club.border-type-thin .board .border {
        stroke: #692e2b;
        stroke-width: 0.7%;
        fill: #af6b3f;
      }

      .cm-chessboard.chess-club.border-type-none .board .border {
        stroke: #692e2b;
        stroke-width: 0;
        fill: #af6b3f;
      }

      .cm-chessboard.chess-club.border-type-frame .board .border {
        fill: #692e2b;
        stroke: none;
      }

      .cm-chessboard.chess-club.border-type-frame .board .border-inner {
        fill: #af6b3f;
        stroke: #692e2b;
        stroke-width: 0.7%;
      }

      .cm-chessboard.chess-club .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.chess-club .coordinates .coordinate {
        fill: #e6d3b1;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.chess-club .coordinates .coordinate.black {
        fill: #e6d3b1;
      }
      .cm-chessboard.chess-club .coordinates .coordinate.white {
        fill: #af6b3f;
      }

      .cm-chessboard.chessboard-js .board .square.white {
        fill: #f0d9b5;
      }

      .cm-chessboard.chessboard-js .board .square.black {
        fill: #b58863;
      }

      .cm-chessboard.chessboard-js.border-type-thin .board .border {
        stroke: #404040;
        stroke-width: 0.7%;
        fill: #b58863;
      }

      .cm-chessboard.chessboard-js.border-type-none .board .border {
        stroke: #404040;
        stroke-width: 0;
        fill: #b58863;
      }

      .cm-chessboard.chessboard-js.border-type-frame .board .border {
        fill: #f0d9b5;
        stroke: none;
      }

      .cm-chessboard.chessboard-js.border-type-frame .board .border-inner {
        fill: #b58863;
        stroke: #404040;
        stroke-width: 0.7%;
      }

      .cm-chessboard.chessboard-js .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.chessboard-js .coordinates .coordinate {
        fill: #404040;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.chessboard-js .coordinates .coordinate.black {
        fill: #f0d9b5;
      }
      .cm-chessboard.chessboard-js .coordinates .coordinate.white {
        fill: #b58863;
      }

      .cm-chessboard.black-and-white .board .square.white {
        fill: #ffffff;
      }

      .cm-chessboard.black-and-white .board .square.black {
        fill: #9c9c9c;
      }

      .cm-chessboard.black-and-white.border-type-thin .board .border {
        stroke: #9c9c9c;
        stroke-width: 0.7%;
        fill: #9c9c9c;
      }

      .cm-chessboard.black-and-white.border-type-none .board .border {
        stroke: #9c9c9c;
        stroke-width: 0;
        fill: #9c9c9c;
      }

      .cm-chessboard.black-and-white.border-type-frame .board .border {
        fill: #ffffff;
        stroke: none;
      }

      .cm-chessboard.black-and-white.border-type-frame .board .border-inner {
        fill: #9c9c9c;
        stroke: #9c9c9c;
        stroke-width: 0.7%;
      }

      .cm-chessboard.black-and-white .coordinates {
        pointer-events: none;
        user-select: none;
      }
      .cm-chessboard.black-and-white .coordinates .coordinate {
        fill: #909090;
        font-size: 7px;
        cursor: default;
      }
      .cm-chessboard.black-and-white .coordinates .coordinate.black {
        fill: white;
      }
      .cm-chessboard.black-and-white .coordinates .coordinate.white {
        fill: #909090;
      }
    </style>
  </template>
}

export class Chess extends CardDef {
  static displayName = 'Chess';

  static isolated = class Isolated extends BoxelComponent<typeof this> {
    get display() {
      return lodash.kebabCase('MagnusCarlsen');
    }

    @field firstName = contains(StringCard);

    <template>
      <div>
        {{this.display}}
      </div>
      <ChessboardComponent />
    </template>
  };
}
