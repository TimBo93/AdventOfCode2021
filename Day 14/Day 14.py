class Sequence:
    def __init__(self, start: str, end: str) -> None:
        self.start = start
        self.end = end

    def __eq__(self, other) -> bool:
        return self.start == other.start and self.end == other.end

class Transition:
    def __init__(self, sequence: Sequence, ingest: str) -> None:
        self.sequence = sequence
        self.ingest =  ingest

class ElementCountMap:
    def __init__(self, sequence: Sequence = None) -> None:
        self.elementCountMap: dict[str, int] = { }

        if(sequence):
            if(sequence.start == sequence.end):
                self.elementCountMap[sequence.start] = 2
            else:
                self.elementCountMap = {
                    sequence.start: 1,
                    sequence.end: 1
                }

    def joinWith(self, other: 'ElementCountMap', sharedElement: str = None) -> 'ElementCountMap':
        copy = dict(self.elementCountMap)
        for itemToJoin in other.elementCountMap:
            if(itemToJoin in self.elementCountMap.keys()):
                copy[itemToJoin] += other.elementCountMap[itemToJoin]
            else:
                copy[itemToJoin] = other.elementCountMap[itemToJoin]
        
        # remove duplicate entry
        if(sharedElement):
            copy[sharedElement] -= 1

        newMap = ElementCountMap(None)
        newMap.elementCountMap = copy
        return newMap

class ElementCountCache:
    def __init__(self) -> None:
        self.cache: dict[str, ElementCountMap] = {}

    def toKey(sequence: Sequence, depth: int) -> str:
        return sequence.start+"$"+sequence.end+"#"+str(depth)

    def contains(self, sequence: Sequence, depth: int):
        return ElementCountCache.toKey(sequence, depth) in self.cache.keys()

    def addToCache(self, sequence: Sequence, depth: int, elementCountMap: ElementCountMap):
        t = ElementCountCache.toKey(sequence, depth)
        self.cache[t] = elementCountMap

    def get(self, sequence: Sequence, depth: int) -> ElementCountMap:
        return self.cache[ElementCountCache.toKey(sequence, depth)]

file1 = open('input.txt', 'r')
lines = file1.readlines()

startLine = lines[0]
transitions: list[Transition] = []

for line in lines[2:]:
    split = line.split()
    transitions.append(Transition(Sequence(split[0][0], split[0][1]), split[2]))

def foldSequence(sequence: Sequence, depth: int) -> ElementCountMap:
    transaction = next(t for t in transitions if t.sequence == sequence)

    if (transaction):
        if(ecc.contains(sequence, depth)):
            return ecc.get(sequence, depth)
        else:
            if(depth == 0):
                return ElementCountMap(sequence)

            foldedLeft = foldSequence(Sequence(sequence.start, transaction.ingest), depth-1)
            foldedRight = foldSequence(Sequence(transaction.ingest, sequence.end), depth-1)
                        
            joined = foldedLeft.joinWith(foldedRight, transaction.ingest)
            ecc.addToCache(sequence, depth, joined)

            return joined
    else:
        return ElementCountMap(sequence)

# execute
accumulationMap = ElementCountMap()
ecc = ElementCountCache()
depth = 40

for element in range(len(startLine) -2):
    sequence = Sequence(startLine[element], startLine[element+1])
    print("from ", sequence.start, " to ", sequence.end)
    ecm = foldSequence(sequence, depth)
    accumulationMap = accumulationMap.joinWith(ecm, startLine[element] if element > 0 else None)

print(accumulationMap.elementCountMap)
r_max = max(accumulationMap.elementCountMap.values())
r_min = min(accumulationMap.elementCountMap.values())
print("max is ", r_max)
print("min is ", r_min)
print("solution = ", r_max-r_min)
