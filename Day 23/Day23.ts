enum AmphipodType { A, B, C, D }

class AmphipodSpecie {
    public static readonly A = new AmphipodSpecie(AmphipodType.A, 1);
    public static readonly B = new AmphipodSpecie(AmphipodType.B, 10);
    public static readonly C = new AmphipodSpecie(AmphipodType.C, 100);
    public static readonly D = new AmphipodSpecie(AmphipodType.D, 1000);

    public static readonly All = [
        AmphipodSpecie.A,
        AmphipodSpecie.B,
        AmphipodSpecie.C,
        AmphipodSpecie.D
    ];

    private constructor(public readonly type: AmphipodType, public readonly energy: number) {
    }
}

enum FieldTypes {
    SideRoom,
    Hallway,
    ImmediatelyOutside,
}

type SideRoom = { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie }
type Hallway = { type: FieldTypes.Hallway }
type ImmediatelyOutside = { type: FieldTypes.ImmediatelyOutside }
type FieldType =
    | SideRoom
    | Hallway
    | ImmediatelyOutside;


class Field {
    public constructor(public readonly posX: number, public readonly posY: number, public readonly fieldType: FieldType) {
    }
}

class Board {
    public readonly allFields: Field[];
    public readonly allHallwayFields: Field[];
    public readonly fieldsByAmphipodType: { [index: number]: Field[] };
    private readonly fieldsByPos: Field[][];

    public constructor(fieldGenerator: (() => Field[]), private readonly gatewayY: number) {
        this.allFields = fieldGenerator();
        Object.freeze(this.allFields);

        this.allHallwayFields = this.allFields.filter(f => f.fieldType.type === FieldTypes.Hallway);
        Object.freeze(this.allHallwayFields);

        this.fieldsByAmphipodType = [];
        AmphipodSpecie.All.map(key => {
            const t = this.allFields.filter(f => f.fieldType.type === FieldTypes.SideRoom && f.fieldType.homeOf === key);
            this.fieldsByAmphipodType[key.type] = t;
        });
        Object.freeze(this.fieldsByAmphipodType);

        this.fieldsByPos = [];
        this.allFields.map(key => {
            if (!this.fieldsByPos[key.posX]) {
                this.fieldsByPos[key.posX] = [];
            }
            this.fieldsByPos[key.posX][key.posY] = key;
        })
        Object.freeze(this.fieldsByPos);
    }

    public getRoute(from: Field, to: Field): Field[] {
        let posX = from.posX;
        let posY = from.posY;

        let route = [];
        while (posX !== to.posX || posY !== to.posY) {

            if (posX !== to.posX) {
                if (posY === this.gatewayY) {
                    // move horizontally until reach of target pos
                    if (posX < to.posX) {
                        posX++;
                    } else {
                        posX--;
                    }
                } else {
                    posY++;
                }
            } else {
                posY--;
            }
            route.push(this.getFieldByPos(posX, posY));
        }

        return route;
    }

    public getFieldByPos(posX: number, posY: number) {
        return this.fieldsByPos[posX][posY];
    }

    public static Part1Generator(): Field[] {
        let fields: Field[] = [];

        [0, 1, 3, 5, 7, 9, 10].forEach(pos => {
            fields.push(new Field(pos, 3, { type: FieldTypes.Hallway }));
        });

        [2, 4, 6, 8].forEach(pos => {
            fields.push(new Field(pos, 3, { type: FieldTypes.ImmediatelyOutside }));
        });

        [1, 2].forEach(pos => {
            fields.push(new Field(2, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.A }));
        });
        [1, 2].forEach(pos => {
            fields.push(new Field(4, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.B }));
        });
        [1, 2].forEach(pos => {
            fields.push(new Field(6, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.C }));
        });
        [1, 2].forEach(pos => {
            fields.push(new Field(8, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.D }));
        });

        return fields;
    }

    public static Part2Generator(): Field[] {
        let fields: Field[] = [];

        [0, 1, 3, 5, 7, 9, 10].forEach(pos => {
            fields.push(new Field(pos, 4, { type: FieldTypes.Hallway }));
        });

        [2, 4, 6, 8].forEach(pos => {
            fields.push(new Field(pos, 4, { type: FieldTypes.ImmediatelyOutside }));
        });

        [0, 1, 2, 3].forEach(pos => {
            fields.push(new Field(2, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.A }));
        });
        [0, 1, 2, 3].forEach(pos => {
            fields.push(new Field(4, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.B }));
        });
        [0, 1, 2, 3].forEach(pos => {
            fields.push(new Field(6, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.C }));
        });
        [0, 1, 2, 3].forEach(pos => {
            fields.push(new Field(8, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.D }));
        });

        return fields;
    }
}

class Amphipod {
    constructor(public readonly species: AmphipodSpecie, public readonly field: Field) {
    }

    public Move(to: Field): Amphipod {
        return new Amphipod(this.species, to);
    }
}

class Move {
    constructor(
        public readonly amphipod: Amphipod,
        public readonly to: Field,
        public readonly isFinishing: boolean, /** when this move would be applied, it moves straight into the house */
        public readonly neededEnergy: number) {
    }
}

class State {
    constructor(
        public readonly amphipods: Amphipod[],
        public readonly board: Board,
    ) {
        Object.freeze(amphipods);
    }

    public isFinished(): boolean {
        for (var i in this.amphipods) {
            const amphipod = this.amphipods[i];
            if (!(amphipod.field.fieldType.type === FieldTypes.SideRoom && amphipod.field.fieldType.homeOf === amphipod.species)) {
                return false;
            }
        }
        return true;
    }

    public applyMove(move: Move): State {
        let amphipods = this.amphipods.filter(a => a !== move.amphipod);
        const moved = move.amphipod.Move(move.to);
        amphipods.push(moved);
        return new State(amphipods, this.board);
    }

    public getAccessibleHallwayFields(amphipod: Amphipod): Field[] {
        const currentField = amphipod.field;

        if (currentField.fieldType.type === FieldTypes.Hallway) {
            return [];
        }

        return this.board.allHallwayFields.filter(targetField => {
            if (this.getAmphipodByField(targetField) !== null) {
                return false;
            }
            const route = this.board.getRoute(currentField, targetField)
            return this.checkRoute(this.board.getRoute(currentField, targetField));
        });
    }

    public ToString(): string {
        let stateAsString = "";

        this.board.allFields.map(field => {
            const speciesAtField = this.getAmphipodByField(field);

            if (speciesAtField === null) {
                stateAsString += ".";
                return;
            } else {
                stateAsString += AmphipodType[speciesAtField.species.type];
            }
        });

        return stateAsString;
    }

    public getAmphipodByField(field: Field): Amphipod | null {
        const amphipod = this.amphipods.filter(x => x.field === field);
        if (amphipod.length > 0) {
            return amphipod[0];
        }
        return null;
    }

    public checkRoute(route: Field[]): boolean {
        for (const key in route) {
            const fieldToCheck = route[key];
            if (this.getAmphipodByField(fieldToCheck) !== null) {
                return false;
            }
        }
        return true;
    }
}

interface ITargetFieldEnumerator {
    getAllTargetsFor(amphipod: Amphipod, state: State): Field[];
}

class TargetFieldEnumeratorPart1 implements ITargetFieldEnumerator {

    public getAllTargetsFor(amphipod: Amphipod, state: State): Field[] {
        const currentField = amphipod.field;

        // if you are already at home in the back -> you dont want to move
        const fieldAtBack = this.getBack(amphipod, state);
        if (currentField === fieldAtBack) {
            return [];
        }

        // if you are in front at your home and in back is your homie -> you dont want to move
        if (currentField === this.getFront(amphipod, state)
            && state.getAmphipodByField(fieldAtBack).species === amphipod.species) {
            return [];
        }

        const back = this.getBack(amphipod, state);
        const amphipodAtBack = state.getAmphipodByField(back)
        if (amphipodAtBack === null) {
            const routeToBack = state.board.getRoute(currentField, back);
            if (state.checkRoute(routeToBack)) {
                return [back];
            } else {
                // no need to check the front field if the back is unreachable
                return state.getAccessibleHallwayFields(amphipod);
            }
        }

        const isFriendAtBack = amphipodAtBack.species === amphipod.species;
        if (isFriendAtBack) {
            const front = this.getFront(amphipod, state);
            const amphipodAtFront = state.getAmphipodByField(front)
            if (amphipodAtFront === null) {
                const routeToFront = state.board.getRoute(currentField, front);
                if (state.checkRoute(routeToFront)) {
                    return [front];
                }
            }
        }

        return state.getAccessibleHallwayFields(amphipod);
    }

    private getBack(amphipod: Amphipod, state: State): Field {
        const posYback = 1;
        return state.board.fieldsByAmphipodType[amphipod.species.type].filter(f => f.posY === posYback)[0];
    }

    private getFront(amphipod: Amphipod, state: State): Field {
        const posYfront = 2;
        return state.board.fieldsByAmphipodType[amphipod.species.type].filter(f => f.posY === posYfront)[0];
    }
}

class TargetFieldEnumeratorPart2 implements ITargetFieldEnumerator {

    public getAllTargetsFor(amphipod: Amphipod, state: State): Field[] {
        if (amphipod.field.fieldType.type === FieldTypes.SideRoom) {
            // if I am in home-zone -> do nothing , if all behind me are friends
            // otherwise -> go outside

            if (this.isCorrect(amphipod, amphipod.field)) {
                // check if all "behind" me are friends
                let allBehindMeAreFriends = true;
                for (var posY = amphipod.field.posY - 1; posY >= 0; posY--) {
                    const posX = amphipod.field.posX;
                    const fieldToCheck = state.board.getFieldByPos(posX, posY);
                    const amphipdAtField = state.getAmphipodByField(fieldToCheck);
                    if (!this.isCorrect(amphipdAtField, fieldToCheck)) {
                        allBehindMeAreFriends = false;
                        break;
                    }
                }

                if (allBehindMeAreFriends) {
                    return [];
                }
            }

            return state.getAccessibleHallwayFields(amphipod);
        }

        // check if I can enter my room: 
        // each must be either friend or empty
        const targetPosX = state.board.fieldsByAmphipodType[amphipod.species.type][0].posX;
        for (var posY = 0; posY < 4; posY++) {
            const fieldToCheck = state.board.getFieldByPos(targetPosX, posY);
            const amphipdAtField = state.getAmphipodByField(fieldToCheck);
            if (amphipdAtField !== null && !this.isCorrect(amphipdAtField, fieldToCheck)) {
                return []; // currently blocked
            }
        }
        // ok there is an empty space
        for (var posY = 0; posY < 4; posY++) {
            const fieldToCheck = state.board.getFieldByPos(targetPosX, posY);
            const amphipdAtField = state.getAmphipodByField(fieldToCheck);
            if (amphipdAtField === null) {
                var route = state.board.getRoute(amphipod.field, fieldToCheck);
                if (state.checkRoute(route)) {
                    return [fieldToCheck];
                } else {
                    return [];
                }
            }
        }
    }

    private isCorrect(amphipod: Amphipod, field: Field): Boolean {
        return amphipod.field.fieldType.type === FieldTypes.SideRoom && amphipod.field.fieldType.homeOf === amphipod.species;
    }
}


class Solver {
    private set: number[] = [];

    constructor(private readonly reachableFieldEnumerator: ITargetFieldEnumerator) {
    }

    public solve(state: State): number {
        const stateAsString = state.ToString();
        const cachedCost = this.set[stateAsString] as number | undefined;
        if (!!cachedCost) {
            return cachedCost;
        }

        if (state.isFinished()) {
            this.set[stateAsString] = 0;
            return 0;
        }

        const allMoves = this.getAllLegalMovesInState(state);
        if (allMoves.length === 0) {
            this.set[stateAsString] = Number.MAX_VALUE;
            return Number.MAX_VALUE;
        }

        // if there is an finishing move, then apply it. The order doesn´t matter.
        const finishingMoves = allMoves.filter(move => move.isFinishing);
        if (finishingMoves.length > 0) {
            const arbitraryFinishingMove = finishingMoves[0];
            const afterApplyingFinishingMove = this.solve(state.applyMove(arbitraryFinishingMove)) + arbitraryFinishingMove.neededEnergy;
            this.set[stateAsString] = afterApplyingFinishingMove;
            return afterApplyingFinishingMove;
        }

        const min = Math.min.apply(Math, allMoves.map(move => {
            return this.solve(state.applyMove(move)) + move.neededEnergy;
        }));
        this.set[stateAsString] = min;
        return min;
    }

    private getAllLegalMovesInState(state: State): Move[] {
        let legalMoves = [];
        state.amphipods.forEach(amphipod => {
            this.reachableFieldEnumerator.getAllTargetsFor(amphipod, state).forEach(target => {
                const isFinishingMove = target.fieldType.type === FieldTypes.SideRoom && target.fieldType.homeOf === amphipod.species;
                const energy = state.board.getRoute(amphipod.field, target).length * amphipod.species.energy;
                legalMoves.push(new Move(amphipod, target, isFinishingMove, energy));
            });
        });
        return legalMoves;
    }
}

// 4#############
// 3#0123456789A#
// 2###D#A#D#C###
// 1  #B#C#B#A#
// 0  #########

const solvePart1 = () => {
    const board = new Board(Board.Part1Generator, 3);
    const state = new State([
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(2, 1)),
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(2, 2)),

        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(4, 1)),
        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(4, 2)),

        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(6, 1)),
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(6, 2)),

        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(8, 1)),
        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(8, 2)),
    ], board);

    const moveEnumerator = new TargetFieldEnumeratorPart1();
    const solver = new Solver(moveEnumerator);
    return solver.solve(state);
}

// #############
// 4#...........#
// 3###D#A#D#C###
// 2  #D#C#B#A#
// 1  #D#B#A#C#
// 0  #B#C#B#A#
//   #########

const solvePart2 = () => {
    const board = new Board(Board.Part2Generator, 4);
    const state = new State([
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(2, 3)),
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(2, 2)),
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(2, 1)),
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(2, 0)),

        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(4, 3)),
        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(4, 2)),
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(4, 1)),
        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(4, 0)),

        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(6, 3)),
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(6, 2)),
        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(6, 1)),
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(6, 0)),

        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(8, 3)),
        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(8, 2)),
        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(8, 1)),
        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(8, 0)),
    ], board);

    const moveEnumerator = new TargetFieldEnumeratorPart2();
    const solver = new Solver(moveEnumerator);
    return solver.solve(state);
}

console.debug(`Part 1 ${solvePart1()}`);
console.debug(`Part 2 ${solvePart2()}`);