var AmphipodType;
(function (AmphipodType) {
    AmphipodType[AmphipodType["A"] = 0] = "A";
    AmphipodType[AmphipodType["B"] = 1] = "B";
    AmphipodType[AmphipodType["C"] = 2] = "C";
    AmphipodType[AmphipodType["D"] = 3] = "D";
})(AmphipodType || (AmphipodType = {}));
var AmphipodSpecie = /** @class */ (function () {
    function AmphipodSpecie(type, energy) {
        this.type = type;
        this.energy = energy;
    }
    AmphipodSpecie.A = new AmphipodSpecie(AmphipodType.A, 1);
    AmphipodSpecie.B = new AmphipodSpecie(AmphipodType.B, 10);
    AmphipodSpecie.C = new AmphipodSpecie(AmphipodType.C, 100);
    AmphipodSpecie.D = new AmphipodSpecie(AmphipodType.D, 1000);
    AmphipodSpecie.All = [
        AmphipodSpecie.A,
        AmphipodSpecie.B,
        AmphipodSpecie.C,
        AmphipodSpecie.D
    ];
    return AmphipodSpecie;
}());
var FieldTypes;
(function (FieldTypes) {
    FieldTypes[FieldTypes["SideRoom"] = 0] = "SideRoom";
    FieldTypes[FieldTypes["Hallway"] = 1] = "Hallway";
    FieldTypes[FieldTypes["ImmediatelyOutside"] = 2] = "ImmediatelyOutside";
})(FieldTypes || (FieldTypes = {}));
var Field = /** @class */ (function () {
    function Field(posX, posY, fieldType) {
        this.posX = posX;
        this.posY = posY;
        this.fieldType = fieldType;
    }
    return Field;
}());
var Board = /** @class */ (function () {
    function Board(fieldGenerator, gatewayY) {
        var _this = this;
        this.gatewayY = gatewayY;
        this.allFields = fieldGenerator();
        Object.freeze(this.allFields);
        this.allHallwayFields = this.allFields.filter(function (f) { return f.fieldType.type === FieldTypes.Hallway; });
        Object.freeze(this.allHallwayFields);
        this.fieldsByAmphipodType = [];
        AmphipodSpecie.All.map(function (key) {
            var t = _this.allFields.filter(function (f) { return f.fieldType.type === FieldTypes.SideRoom && f.fieldType.homeOf === key; });
            _this.fieldsByAmphipodType[key.type] = t;
        });
        Object.freeze(this.fieldsByAmphipodType);
        this.fieldsByPos = [];
        this.allFields.map(function (key) {
            if (!_this.fieldsByPos[key.posX]) {
                _this.fieldsByPos[key.posX] = [];
            }
            _this.fieldsByPos[key.posX][key.posY] = key;
        });
        Object.freeze(this.fieldsByPos);
    }
    Board.prototype.getRoute = function (from, to) {
        var posX = from.posX;
        var posY = from.posY;
        var route = [];
        while (posX !== to.posX || posY !== to.posY) {
            if (posX !== to.posX) {
                if (posY === this.gatewayY) {
                    // move horizontally until reach of target pos
                    if (posX < to.posX) {
                        posX++;
                    }
                    else {
                        posX--;
                    }
                }
                else {
                    posY++;
                }
            }
            else {
                posY--;
            }
            route.push(this.getFieldByPos(posX, posY));
        }
        return route;
    };
    Board.prototype.getFieldByPos = function (posX, posY) {
        return this.fieldsByPos[posX][posY];
    };
    Board.Part1Generator = function () {
        var fields = [];
        [0, 1, 3, 5, 7, 9, 10].forEach(function (pos) {
            fields.push(new Field(pos, 3, { type: FieldTypes.Hallway }));
        });
        [2, 4, 6, 8].forEach(function (pos) {
            fields.push(new Field(pos, 3, { type: FieldTypes.ImmediatelyOutside }));
        });
        [1, 2].forEach(function (pos) {
            fields.push(new Field(2, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.A }));
        });
        [1, 2].forEach(function (pos) {
            fields.push(new Field(4, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.B }));
        });
        [1, 2].forEach(function (pos) {
            fields.push(new Field(6, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.C }));
        });
        [1, 2].forEach(function (pos) {
            fields.push(new Field(8, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.D }));
        });
        return fields;
    };
    Board.Part2Generator = function () {
        var fields = [];
        [0, 1, 3, 5, 7, 9, 10].forEach(function (pos) {
            fields.push(new Field(pos, 4, { type: FieldTypes.Hallway }));
        });
        [2, 4, 6, 8].forEach(function (pos) {
            fields.push(new Field(pos, 4, { type: FieldTypes.ImmediatelyOutside }));
        });
        [0, 1, 2, 3].forEach(function (pos) {
            fields.push(new Field(2, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.A }));
        });
        [0, 1, 2, 3].forEach(function (pos) {
            fields.push(new Field(4, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.B }));
        });
        [0, 1, 2, 3].forEach(function (pos) {
            fields.push(new Field(6, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.C }));
        });
        [0, 1, 2, 3].forEach(function (pos) {
            fields.push(new Field(8, pos, { type: FieldTypes.SideRoom, homeOf: AmphipodSpecie.D }));
        });
        return fields;
    };
    return Board;
}());
var Amphipod = /** @class */ (function () {
    function Amphipod(species, field) {
        this.species = species;
        this.field = field;
    }
    Amphipod.prototype.Move = function (to) {
        return new Amphipod(this.species, to);
    };
    return Amphipod;
}());
var Move = /** @class */ (function () {
    function Move(amphipod, to, isFinishing, /** when this move would be applied, it moves straight into the house */ neededEnergy) {
        this.amphipod = amphipod;
        this.to = to;
        this.isFinishing = isFinishing;
        this.neededEnergy = neededEnergy;
    }
    return Move;
}());
var State = /** @class */ (function () {
    function State(amphipods, board) {
        this.amphipods = amphipods;
        this.board = board;
        Object.freeze(amphipods);
    }
    State.prototype.isFinished = function () {
        for (var i in this.amphipods) {
            var amphipod = this.amphipods[i];
            if (!(amphipod.field.fieldType.type === FieldTypes.SideRoom && amphipod.field.fieldType.homeOf === amphipod.species)) {
                return false;
            }
        }
        return true;
    };
    State.prototype.applyMove = function (move) {
        var amphipods = this.amphipods.filter(function (a) { return a !== move.amphipod; });
        var moved = move.amphipod.Move(move.to);
        amphipods.push(moved);
        return new State(amphipods, this.board);
    };
    State.prototype.getAccessibleHallwayFields = function (amphipod) {
        var _this = this;
        var currentField = amphipod.field;
        if (currentField.fieldType.type === FieldTypes.Hallway) {
            return [];
        }
        return this.board.allHallwayFields.filter(function (targetField) {
            if (_this.getAmphipodByField(targetField) !== null) {
                return false;
            }
            var route = _this.board.getRoute(currentField, targetField);
            return _this.checkRoute(_this.board.getRoute(currentField, targetField));
        });
    };
    State.prototype.ToString = function () {
        var _this = this;
        var stateAsString = "";
        this.board.allFields.map(function (field) {
            var speciesAtField = _this.getAmphipodByField(field);
            if (speciesAtField === null) {
                stateAsString += ".";
                return;
            }
            else {
                stateAsString += AmphipodType[speciesAtField.species.type];
            }
        });
        return stateAsString;
    };
    State.prototype.getAmphipodByField = function (field) {
        var amphipod = this.amphipods.filter(function (x) { return x.field === field; });
        if (amphipod.length > 0) {
            return amphipod[0];
        }
        return null;
    };
    State.prototype.checkRoute = function (route) {
        for (var key in route) {
            var fieldToCheck = route[key];
            if (this.getAmphipodByField(fieldToCheck) !== null) {
                return false;
            }
        }
        return true;
    };
    return State;
}());
var TargetFieldEnumeratorPart1 = /** @class */ (function () {
    function TargetFieldEnumeratorPart1() {
    }
    TargetFieldEnumeratorPart1.prototype.getAllTargetsFor = function (amphipod, state) {
        var currentField = amphipod.field;
        // if you are already at home in the back -> you dont want to move
        var fieldAtBack = this.getBack(amphipod, state);
        if (currentField === fieldAtBack) {
            return [];
        }
        // if you are in front at your home and in back is your homie -> you dont want to move
        if (currentField === this.getFront(amphipod, state)
            && state.getAmphipodByField(fieldAtBack).species === amphipod.species) {
            return [];
        }
        var back = this.getBack(amphipod, state);
        var amphipodAtBack = state.getAmphipodByField(back);
        if (amphipodAtBack === null) {
            var routeToBack = state.board.getRoute(currentField, back);
            if (state.checkRoute(routeToBack)) {
                return [back];
            }
            else {
                // no need to check the front field if the back is unreachable
                return state.getAccessibleHallwayFields(amphipod);
            }
        }
        var isFriendAtBack = amphipodAtBack.species === amphipod.species;
        if (isFriendAtBack) {
            var front = this.getFront(amphipod, state);
            var amphipodAtFront = state.getAmphipodByField(front);
            if (amphipodAtFront === null) {
                var routeToFront = state.board.getRoute(currentField, front);
                if (state.checkRoute(routeToFront)) {
                    return [front];
                }
            }
        }
        return state.getAccessibleHallwayFields(amphipod);
    };
    TargetFieldEnumeratorPart1.prototype.getBack = function (amphipod, state) {
        var posYback = 1;
        return state.board.fieldsByAmphipodType[amphipod.species.type].filter(function (f) { return f.posY === posYback; })[0];
    };
    TargetFieldEnumeratorPart1.prototype.getFront = function (amphipod, state) {
        var posYfront = 2;
        return state.board.fieldsByAmphipodType[amphipod.species.type].filter(function (f) { return f.posY === posYfront; })[0];
    };
    return TargetFieldEnumeratorPart1;
}());
var TargetFieldEnumeratorPart2 = /** @class */ (function () {
    function TargetFieldEnumeratorPart2() {
    }
    TargetFieldEnumeratorPart2.prototype.getAllTargetsFor = function (amphipod, state) {
        if (amphipod.field.fieldType.type === FieldTypes.SideRoom) {
            // if I am in home-zone -> do nothing , if all behind me are friends
            // otherwise -> go outside
            if (this.isCorrect(amphipod, amphipod.field)) {
                // check if all "behind" me are friends
                var allBehindMeAreFriends = true;
                for (var posY = amphipod.field.posY - 1; posY >= 0; posY--) {
                    var posX = amphipod.field.posX;
                    var fieldToCheck = state.board.getFieldByPos(posX, posY);
                    var amphipdAtField = state.getAmphipodByField(fieldToCheck);
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
        var targetPosX = state.board.fieldsByAmphipodType[amphipod.species.type][0].posX;
        for (var posY = 0; posY < 4; posY++) {
            var fieldToCheck = state.board.getFieldByPos(targetPosX, posY);
            var amphipdAtField = state.getAmphipodByField(fieldToCheck);
            if (amphipdAtField !== null && !this.isCorrect(amphipdAtField, fieldToCheck)) {
                return []; // currently blocked
            }
        }
        // ok there is an empty space
        for (var posY = 0; posY < 4; posY++) {
            var fieldToCheck = state.board.getFieldByPos(targetPosX, posY);
            var amphipdAtField = state.getAmphipodByField(fieldToCheck);
            if (amphipdAtField === null) {
                var route = state.board.getRoute(amphipod.field, fieldToCheck);
                if (state.checkRoute(route)) {
                    return [fieldToCheck];
                }
                else {
                    return [];
                }
            }
        }
    };
    TargetFieldEnumeratorPart2.prototype.isCorrect = function (amphipod, field) {
        return amphipod.field.fieldType.type === FieldTypes.SideRoom && amphipod.field.fieldType.homeOf === amphipod.species;
    };
    return TargetFieldEnumeratorPart2;
}());
var Solver = /** @class */ (function () {
    function Solver(reachableFieldEnumerator) {
        this.reachableFieldEnumerator = reachableFieldEnumerator;
        this.set = [];
    }
    Solver.prototype.solve = function (state) {
        var _this = this;
        var stateAsString = state.ToString();
        var cachedCost = this.set[stateAsString];
        if (!!cachedCost) {
            return cachedCost;
        }
        if (state.isFinished()) {
            this.set[stateAsString] = 0;
            return 0;
        }
        var allMoves = this.getAllLegalMovesInState(state);
        if (allMoves.length === 0) {
            this.set[stateAsString] = Number.MAX_VALUE;
            return Number.MAX_VALUE;
        }
        // if there is an finishing move, then apply it. The order doesn´t matter.
        var finishingMoves = allMoves.filter(function (move) { return move.isFinishing; });
        if (finishingMoves.length > 0) {
            var arbitraryFinishingMove = finishingMoves[0];
            var afterApplyingFinishingMove = this.solve(state.applyMove(arbitraryFinishingMove)) + arbitraryFinishingMove.neededEnergy;
            this.set[stateAsString] = afterApplyingFinishingMove;
            return afterApplyingFinishingMove;
        }
        var min = Math.min.apply(Math, allMoves.map(function (move) {
            return _this.solve(state.applyMove(move)) + move.neededEnergy;
        }));
        this.set[stateAsString] = min;
        return min;
    };
    Solver.prototype.getAllLegalMovesInState = function (state) {
        var _this = this;
        var legalMoves = [];
        state.amphipods.forEach(function (amphipod) {
            _this.reachableFieldEnumerator.getAllTargetsFor(amphipod, state).forEach(function (target) {
                var isFinishingMove = target.fieldType.type === FieldTypes.SideRoom && target.fieldType.homeOf === amphipod.species;
                var energy = state.board.getRoute(amphipod.field, target).length * amphipod.species.energy;
                legalMoves.push(new Move(amphipod, target, isFinishingMove, energy));
            });
        });
        return legalMoves;
    };
    return Solver;
}());
// 4#############
// 3#0123456789A#
// 2###D#A#D#C###
// 1  #B#C#B#A#
// 0  #########
var solvePart1 = function () {
    var board = new Board(Board.Part1Generator, 3);
    var state = new State([
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(2, 1)),
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(2, 2)),
        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(4, 1)),
        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(4, 2)),
        new Amphipod(AmphipodSpecie.B, board.getFieldByPos(6, 1)),
        new Amphipod(AmphipodSpecie.D, board.getFieldByPos(6, 2)),
        new Amphipod(AmphipodSpecie.A, board.getFieldByPos(8, 1)),
        new Amphipod(AmphipodSpecie.C, board.getFieldByPos(8, 2)),
    ], board);
    var moveEnumerator = new TargetFieldEnumeratorPart1();
    var solver = new Solver(moveEnumerator);
    return solver.solve(state);
};
// #############
// 4#...........#
// 3###D#A#D#C###
// 2  #D#C#B#A#
// 1  #D#B#A#C#
// 0  #B#C#B#A#
//   #########
var solvePart2 = function () {
    var board = new Board(Board.Part2Generator, 4);
    var state = new State([
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
    var moveEnumerator = new TargetFieldEnumeratorPart2();
    var solver = new Solver(moveEnumerator);
    return solver.solve(state);
};
console.debug("Part 1 ".concat(solvePart1()));
console.debug("Part 2 ".concat(solvePart2()));
//# sourceMappingURL=Day23.js.map