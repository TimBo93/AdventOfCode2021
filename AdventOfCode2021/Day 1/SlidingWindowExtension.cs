

// calculate increments


public static class SlidingWindowExtension
{
    public static IEnumerable<T[]> GetSlidingWindow<T>(this T[] items, int count)
    {
        if(count <=0)
        {
            throw new ArgumentException($"{nameof(count)} must be greater 0.");
        }
        if(items.Count() < count)
        {
            yield return Array.Empty<T>();
            yield break;
        }
        
        for(var i=0; i<items.Count()-(count - 1); i++)
        {
            var slidingWindow = new List<T>();
            for(var j=0; j<count; j++)
            {
                slidingWindow.Add(items[i + j]);
            }
            yield return slidingWindow.ToArray();
        }
    }
} 


