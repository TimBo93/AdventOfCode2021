using var streamReader = File.OpenText("Day 1/input.txt");
var lines = new List<string>();

while(true)
{
    var line = await streamReader.ReadLineAsync();
    if(line == null)
    {
        break;
    }
    lines.Add(line);
}

var count = lines.Select(x => int.Parse(x)).ToArray().GetSlidingWindow(2).Where(x => x[0] < x[1]).Count();
var count2 = lines
    .Select(x => int.Parse(x)).ToArray()
    .GetSlidingWindow(3).Select(x => x.Sum()).ToArray()
    .GetSlidingWindow(2).Where(x => x[0] < x[1])
    .Count();


Console.WriteLine($"the part1 count is {count}");
Console.WriteLine($"the part2 count is {count2}");
