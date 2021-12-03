use std::{path::Path, fs::File, io::{BufReader, self, BufRead}};

use regex::Regex;

fn main() {
    part1();
    part2();
}

fn part1() {
    let lines = read_lines().unwrap();
    let re = Regex::new(r"(\w+)\s(\d+)").unwrap();
    
    let mut horizontal = 0;
    let mut depth = 0;
    
    for line in lines {
        for cap in re.captures_iter(&line) {
            let direction  = &cap[1];
            let amount = &cap[2].parse::<i32>().unwrap();
    
            match direction {
                "forward" => horizontal += amount,
                "backward" => horizontal -= amount,
                "up" => depth -= amount,
                "down" => depth += amount,
                _ => {println!("some invalid line found {}", line)}
            };
        }
    }

    println!("Horizontal is {}", horizontal);
    println!("Depth is {}", depth);
    println!("Horizontal * Depth is {}", depth * &horizontal)
}

fn part2() {
    let lines = read_lines().unwrap();
    let re = Regex::new(r"(\w+)\s(\d+)").unwrap();
    
    let mut horizontal = 0;
    let mut depth = 0;
    let mut aim = 0;
    
    for line in lines {
        for cap in re.captures_iter(&line) {
            let direction  = &cap[1];
            let amount = &cap[2].parse::<i32>().unwrap();
    
            match direction {
                "forward" => {
                    horizontal += amount;
                    depth += aim * amount;
                },
                "backward" => horizontal -= amount,
                "up" => aim -= amount,
                "down" => aim += amount,
                _ => {println!("some invalid line found {}", line)}
            };
        }
    }

    println!("Horizontal is {}", horizontal);
    println!("Depth is {}", depth);
    println!("Horizontal * Depth is {}", depth * &horizontal)
}

fn read_lines() -> io::Result<Vec<String>> {
    let file = File::open("input.txt")?;
    let reader = BufReader::new(file);

    let mut v = Vec::new();
    for line in reader.lines() {
        v.push(line?);
    }

    Ok(v)
}