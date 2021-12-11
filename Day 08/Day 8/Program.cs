using var file = File.OpenRead("input.txt");
using var fileReader = new StreamReader(file);

int numberOf_1_4_7_8 = 0;
var lines = ReadLines(fileReader).ToArray();

// Part 1
foreach (var item in lines)
{
    numberOf_1_4_7_8 += item.outputSignals.Where(x => x.Length == 2 || x.Length == 4 || x.Length == 3 || x.Length == 7).Count();
}
Console.WriteLine(numberOf_1_4_7_8);


// Part 2
var sumOfAll = lines.Select(line =>
{
    var permutation = GetPermutations("", "abcdefg")
        .First(p => line.inputSignals
                .All(inputSignal => IsValid(ApplyPermutation(inputSignal, p))) 
            && line.outputSignals
                .All(outputSignal => IsValid(ApplyPermutation(outputSignal, p))));
    var number = line.outputSignals.Select(os => GetNumber(ApplyPermutation(os, permutation))).Aggregate((a, b) => a * 10 + b);
    return number;
}).Sum();
Console.WriteLine(sumOfAll);

IEnumerable<Line> ReadLines(StreamReader reader)
{
    while (!reader.EndOfStream)
    {
        var line = reader.ReadLine();
        if (line == null) yield break;
        yield return new Line(line);
    }
}

IEnumerable<string> GetPermutations(string currentPermutation, string openCharacters)
{
    if (openCharacters == "")
    {
        yield return currentPermutation;
        yield break;
    }

    foreach (var item in openCharacters)
    {
        string newPermutation = currentPermutation + item;
        string openChars = openCharacters.Replace($"{item}", string.Empty);

        foreach (var perm in GetPermutations(newPermutation, openChars))
        {
            yield return perm;
        }
    }
}

static byte[] ApplyPermutation(string signal, string permutation)
{
    return signal.ToCharArray().Select(x => (byte)permutation.IndexOf(x)).ToArray();
}

static bool ContainsAll(byte[] signal, byte[] reference)
{
    if(reference.Length != signal.Length)
    {
        return false;
    }
    foreach (var item in reference)
    {
        if(!signal.Contains(item))
        {
            return false;
        }
    }
    return true;
}

static int GetNumber(byte[] signal)
{
    // 0 
    if (ContainsAll(signal, new byte[] { 0, 2, 5, 6, 4, 1 })) return 0;

    // 1
    if (ContainsAll(signal, new byte[] { 2,5 })) return 1;

    // 2
    if (ContainsAll(signal, new byte[] { 0,2,3,4,6 })) return 2;

    // 3
    if (ContainsAll(signal, new byte[] { 0,2,3,5,6 })) return 3;

    // 4
    if (ContainsAll(signal, new byte[] { 1,2,3,5 })) return 4;

    // 5
    if (ContainsAll(signal, new byte[] { 0,1,3,5,6 })) return 5;

    // 6
    if (ContainsAll(signal, new byte[] { 0,1,4,3,5,6 })) return 6;

    // 7
    if (ContainsAll(signal, new byte[] { 0,2,5 })) return 7;

    // 8
    if (ContainsAll(signal, new byte[] { 0,1,2,3,4,5,6 })) return 8;

    // 9
    if (ContainsAll(signal, new byte[] { 0, 1, 2, 3, 5, 6 })) return 9;

    return -1;
}

static bool IsValid(byte[] signals)
{
    return GetNumber(signals) >= 0;
}

class Line
{
    public Line(string line)
    {
        var tokens = line.Split(' ');
        List<string> inputs = new(), outputs = new();
        bool isInput = true;
        foreach (var item in tokens)
        {
            if(item == "|")
            {
                isInput = false;
                continue;
            }
            if(isInput)
            {
                inputs.Add(item);
            }else
            {
                outputs.Add(item);
            }
            inputSignals = inputs.AsReadOnly();
            outputSignals = outputs.AsReadOnly();
        }
    }

    public IReadOnlyList<string> inputSignals { get; }

    public IReadOnlyList<string> outputSignals { get; }
}
