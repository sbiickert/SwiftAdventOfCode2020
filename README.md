# SwiftAdventOfCode2020

Code challenge solutions by me for the Advent of Code 2020.

I decided that I would do this in Swift Playgrounds, but now that I'm four days in, I am questioning that. There is a fair bit of string parsing in these challenges. I think Python or Perl might have been a sounder choice. But in for a penny, in for a pound...

https://adventofcode.com/2020

I was notified of the challenge by [mradamclark](https://github.com/mradamclark)

## Thoughts 15 Days In

I have really enjoyed this. Every day there's a sense of fear, that there will be a challenge that I won't be able to solve. So far, there have been two days where I needed to reach out to the Internet for assistance.

The first such day was Day 10, trying to figure out the total number of possible adapter combinations. I beat my brains out for over a day before giving up. But I didn't just give up: I found a solution and translated it to Swift and made it work. Picked myself up and kept going. The second day was Day 13, with the bus schedules. I knew that there had to be a mathematical combinatorial way to approach it, but my brain couldn't see it. Once I got a hint, I was off to the races.

But other than those two examples, the rest of the challenges might have been tricky at times but solvable in the end. The only solution that I think is "ugly" is Day 4. That was the passport-checking challenge, and my business rule code is so hard-coded it makes my skin crawl. I would say my favorite so far was Day 5, checking tickets with the binary encoded seat numbers. It just felt weightless.

Who knows what is up ahead? We'll know about Day 16 in just under an hour and a half.

## On My Choice of Swift

It's been interesting. While the first few days were very heavy on the text processing (more code was spent reading and parsing the input than in solving the problems), there have been a number of challenges that I could imagine solving with Perl but it might not have been pretty. Swift has nice iterator patterns and there have been two challenges where the ability to read/write numbers as binary strings has been valuable. I have used structs, classes and enums where appropriate. I've surprised myself with the number of times I've used map, compactMap and reduce. Regular expressions are my weapon of choice for text parsing, but they sure aren't elegant in Swift/Foundation.

I would say that the bigger influence on my solutions is not the language, but the programmer. I have habits that come from my days doing business programming, where the clarity of the object model and the way things get called takes precedence over a "clever" algorithm. Day 11 was the epitome of that: I'm sure there were ways to solve the Waiting Area problem in 1/10th the code, but in the end the code just showed the way I thought about it.

I am jealous of those with the skills to do these challenges in really odd environments, like C64 assembly and other weird things. But I'd say most people would think my choice of Swift was weird, in its own way.

## Thoughts 21 Days In

Now the road gets bumpy. Day 19 was a complete failure: not even a brute-force attempt got me to part 2. Day 20 was code I was proud of, but when submitting the answer for part 2, the system told me it was wrong. Only 1/4 stars for two day's work. I thought maybe my advent was coming to an end where my skills ran out. But today I got two stars and part 2 was just an extra print statement away with no extra work.

My achilles heel is recursion. For some reason, I have trouble visualizing deeply-nested calls and what state will come back when the functions unwind. And then my image-jigsaw-tiling solutioning for Day 20 was spot on, and you'd think that would be harder.

## Thoughts at the End

It's done! I didn't think I would have time on Christmas to do the last day, but it turned out to be trivial as long as you can follow directions. At only 57 lines of code, it was over quickly. But then I found out that you didn't get the big "huzzah" at the end unless you got full stars on all the previous days, too. Since I got stumped on Day 19, I was only at 47 stars. I sat on it for about a day before making up my mind that I would get Day 19 done. I found a published solution (https://dev.to/qviper/advent-of-code-2020-python-solution-day-19-4p9d) in Python, and did the work of translating it to Swift. It was not trivial, but I knew that I would get there eventually.

And so now it's done. I'm really happy and energized about it. I needed help for 3 of the 25 days and there is a lot of code here that I'm proud of. Definitely will make time for AoC next year.
