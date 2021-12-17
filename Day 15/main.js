
const fs = require('fs');
const readline = require('readline');

// aka Heap
var PriorityQueue = function() {
    this.items =  [];

    this._swap = function(index1, index2) {
        const tmpIndex = index1;
        const tmpItem = this.items[index1];
        this.items[index1] = this.items[index2];
        this.items[index2] = tmpItem;
    }

    this.enqueue = function(item, value) {
        this.items.push({
            item: item,
            value: value
        });
        
        var currentIndex = this.items.length - 1;
        const currentItem = this.items[currentIndex];

        while(currentIndex > 0) {
            const parentIndex = this.getParentIndex(currentIndex);
            const parentItem = this.items[parentIndex];

            if(currentItem.value < parentItem.value) {
                this._swap(parentIndex, currentIndex);
                currentIndex = parentIndex;
            } else {
                return;
            }
        }
    }

    this.numChilds = function(index) {
        var numChildren = 0;
        if ((index*2+1) < this.items.length) numChildren++
        if ((index*2+2) < this.items.length) numChildren++
        return numChildren;
    }

    this.getParentIndex = function(index) {
        return Math.floor((index - 1) / 2);
    }

    this.rightIndex = function(index) {
        return index * 2 + 2;
    }

    this.leftIndex = function(index) {
        return index * 2 + 1;
    }

    this.dequeue = function() {
        if(this.items.length == 0) {
            throw new error("no item");
        }

        const result = this.items[0].item;

        // move last item to top
        const lastItem = this.items.pop();
        this.items[0] = lastItem;

        var currentIndex = 0;
        const currentItem = this.items[currentIndex];
        
        while(true) {
            const numChilds = this.numChilds(currentIndex);
            if(numChilds == 0) {
                break;
            } 
            else if(numChilds == 1) {
                const leftIndex = this.leftIndex(currentIndex);
                const leftItem = this.items[leftIndex];
                if(leftItem.value < currentItem.value) {
                    this._swap(leftIndex, currentIndex);
                    currentIndex = leftIndex;
                    continue;
                }
                break;
            } 
            else if(numChilds == 2) {
                const leftIndex = this.leftIndex(currentIndex);
                const leftItem = this.items[leftIndex];

                const rightIndex = this.rightIndex(currentIndex);
                const rightItem = this.items[rightIndex];

                var smallerItem;
                var smallerIndex;
                if(leftItem.value < rightItem.value) {
                    smallerItem = leftItem;
                    smallerIndex = leftIndex;
                } else {
                    smallerItem = rightItem;
                    smallerIndex = rightIndex;
                }
                
                if(smallerItem.value < currentItem.value) {
                    this._swap(smallerIndex, currentIndex);
                    currentIndex = smallerIndex;
                    continue;
                }
                break;
            }
        }

        return result;
    }    
}

var Coordinate = function(x, y) {
    this.x = x;
    this.y = y;

    this.equals = function(other) {
        return this.x == other.x && this.y == other.y;
    }
}

var Node = function(coordinate) {
    this.coordinate = coordinate;
    this.hasVisited = false;
    this.risk = 0;

    this.visit = function(risk) {
        this.risk = risk;
        this.hasVisited = true;
    }
}

var Path = function(currentCoordinate, risk, currentPath) {
    this.coordinate = currentCoordinate;
    this.risk = 0;
    this.currentPath = [];    
}

var Candidate = function(to, risk) {
    this.to = to;
    this.risk = risk;
}

var NodeMap = function(caveMap) {
    this.caveMap = caveMap;

    this.nodes = new Array();
    var r = 0;
    for (const row in caveMap) {
        var c = 0;
        var nodeRow = new Array();
        for (const column in caveMap) {
            nodeRow.push(new Node(new Coordinate(c, r)));
            c++;
        }
        r++;
        this.nodes[row] = nodeRow;
    }
    this.numRows = this.nodes.length;
    this.nomColumns = this.nodes[0].length;

    this.getAllNeighbors = function(coordinate) {
        const x = coordinate.x;
        const y = coordinate.y;
        const allNeighbors = [];
        if(x-1 > 0) { allNeighbors.push(new Coordinate(x-1, y) ) }
        if(x+1 < this.numRows) { allNeighbors.push(new Coordinate(x+1, y) ) }
        if(y-1 > 0) { allNeighbors.push(new Coordinate(x, y-1) ) }
        if(y+1 < this.nomColumns) { allNeighbors.push(new Coordinate(x, y+1) ) }
        return allNeighbors;
    }

    this.getNode = function(coordinate) {
        return this.nodes[coordinate.y][coordinate.x];
    }

    this.getRisk = function(coordinate) {
        return this.caveMap[coordinate.y][coordinate.x];
    }

    this.solve = function(from, to) {
        const addNextCandidatesToTravel = function(nodeToExpand, priorityQueue, self) {
            const neighborsCoordinate = self.getAllNeighbors(nodeToExpand.coordinate);
            for(const n in neighborsCoordinate) {
                const targetCoordinate = neighborsCoordinate[n];
                const targetNode = self.getNode(targetCoordinate);
                if(!targetNode.hasVisited) {
                    const transferRisk = nodeToExpand.risk + self.getRisk(targetCoordinate);
                    const riskToVisitWithDistanceToTarget = transferRisk + (Math.abs(targetCoordinate.x - to.x)) + (Math.abs(targetCoordinate.y - to.y));
                    // this optimization is known from the A*-Algorithm
                    priorityQueue.enqueue(new Candidate(targetCoordinate, transferRisk), riskToVisitWithDistanceToTarget);
                }
            }
        }

        const processTravelCandidate = function(travelCandidateToApply, priorityQueue, self) {
            const nodeToTravelTo = self.getNode(travelCandidateToApply.to);

            if (nodeToTravelTo.hasVisited) {
                return;
            }

            nodeToTravelTo.visit(travelCandidateToApply.risk);
            addNextCandidatesToTravel(nodeToTravelTo, priorityQueue, self);
        }

        const priorityQueue = new PriorityQueue();
        processTravelCandidate(new Candidate(from, 0), priorityQueue, this);

        while(true) {
            const next = priorityQueue.dequeue();        
            processTravelCandidate(next, priorityQueue, this);

            if(next.to.equals(to)) {
                console.debug("finished " + this.getNode(next.to).risk);
                return;
            }
        }
    }
}

var CalculatePath = function(caveMap) {
    const nodeMap = new NodeMap(caveMap);
    const startCoordinate = new Coordinate(0, 0);
    const endCoordinate = new Coordinate(nodeMap.numRows-1, nodeMap.nomColumns-1);
    nodeMap.solve(startCoordinate, endCoordinate);
}

async function processLineByLine() {
    const rows = new Array();

    const fileStream = fs.createReadStream('input.txt');

    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });
    for await (const line of rl) {
        var row = new Array();
        for(i in line) {
            row.push(parseInt(line[i]));
        }
        rows.push(row);
    }

    // Part 1
    CalculatePath(rows);

    // Part 2
    function transformToPart2(map){
        var transformed = [];
        const width = map[0].length;
        const height = map.length;

        for(var yi=0; yi<5; yi++) {
            for(var y=0; y<height; y++) {
                    
                var row = [];
                for(var xi = 0 ; xi<5; xi++) {
                    for(var x=0; x<width; x++) {
                        row[xi * width + x] = ((((map[y][x] + xi + yi - 1) % 9) + 9) % 9) + 1;
                    }
                }
                transformed[yi * height + y] = row;

            }
        }

        return transformed;
    }
    CalculatePath(transformToPart2(rows));
}
processLineByLine();
