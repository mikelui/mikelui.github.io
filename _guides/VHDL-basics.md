---
published: true
layout: post
title: "VHDL Student Primer"
subtitle: "Important Concepts"
background: /img/The-Simpsons-Season-23-Episode-11-25-6c0b.jpg
date: 2018-07-07T00:00:00.000Z
author: Mike Lui
---

# What is VHDL?

You're taking the **Digital Logic** class[^1] and figure you'll be doing some `beep boop bop` 🤖 binary things.
You'd be right.
In class, you'll learn boolean logic theory.
With the VHDL labs, you'll see how that theory can be used to make something more concrete.

VHDL is a programming language to describe circuits.
It literally stands for: **V**HSIC (a nested acronym 🙄) **Hardware Description Language**.
VHDL targets digital circuits in contrast to analog circuits.
While *analog* circuits consider electrical properties like impedance, capacitance, et al,
*digital* circuits consider logical properties; 1's and 0's; Yes's and No's.

Here's a taste:

{% highlight vhdl linenos %}
ENTITY inverter IS
    PORT ( in1 : IN BIT; out1 : OUT BIT);
END inverter;

ARCHITECTURE behav OF inverter IS
BEGIN
    out1 <= NOT in1;
END behav;
{% endhighlight %}

Although the syntax is a bit clunky, you can see how we're just defining an inverter.
First, we declare the inputs and outputs of our circuit block.
Then, we describe how the input is transformed into the output.
We're describing the following equation:

$$
\begin{align*}
inverter(a) = a'
\end{align*}
$$

*Amaaahzing* right? Later on we'll go into more details on the syntax.

[^1]:
    The introductory digital design and VHDL class I've had to TA ([ECE-200][ece200]) attracts students
    with a wide variety of backgrounds.
    While some students learn just fine with the provided tutorials and labs,
    others can be turned off by them.
    Even then, students tend to miss some fundamental concepts when going through the
    motions of the labs.

    As such, I've decided to provide a quickstart guide with a slightly different flavor.
    This is **not** meant to be a full reference.
    If you need to know something specific please [find a more complete reference][searchvhdl].

[ece200]: http://catalog.drexel.edu/coursedescriptions/quarter/undergrad/ece/
[searchvhdl]: https://duckduckgo.com/?q=vhdl+reference

-----------

# Why is VHDL?

Why would we want to model digital circuits?
It's easier to understand, modify, simulate, and test our designs by modeling our circuits in VHDL.
VHDL also provides a common format to use starting from initial prototyping and eventually ending at design for manufacturing.

For example imagine trying to build this **thing**:

![a_thing](/img/posts/a_thing.png){:width="100%"}

I could pass this around as just my *schematic*

That doesn't look too complicated.
I have some wires on the left going into a couple components which do something,
then we read from the outputs on the right.

-----------

# How is VHDL?


{::comment}
# Cool.
![Cool](https://i.imgflip.com/1oq3ej.jpg){:width="100%"}
{:/comment}



You *model* the circuit with a programming language,
just like you'd *model* a series of computations with any other programming language.
But instead of describing a series of steps for the computer to execute,
you use VHDL to describe how the circuit is connected.

Remember the **thing** I drew before?
Let's describe it with VHDL.

{% highlight vhdl linenos %}
-- Inputs and Outputs of a thing!
ENTITY a_thing IS
    PORT ( a : IN BIT;
           b : IN BIT;
           c : OUT BIT;
           d : OUT BIT;
         );
END a_thing;

-- The inside guts of a thing!
ARCHITECTURE behav OF a_thing IS
    SIGNAL s1, s2 : BIT;
BEGIN
    s1 <= a AND b; -- Assign/Map c to the result of
                   -- the built-in 'AND' operation

    s2 <= a XOR b; -- Assign/Map d to the result of
                   -- the built-in 'XOR' operation

    c <= s1; -- Assign/Map output c to s1
    d <= s2; -- Assign/Map output d to s2
END behav;
{% endhighlight %}

There's a bunch to unpack here.

#### 1) a_thing is a module

We have what's called a VHDL ***module***.
A module is a full description of a thing. 
It describes:
 - The **`ENTITY`** -- the inputs and outputs; our interface to *a_thing*
 - The **`ARCHITECTURE`** -- how the inputs get transformed into the output

A module **is not** a VHDL file.
A module could be spread across one or more files, and a single file might have multiple modules.

#### 2) Syntax

Keywords, Identifiers, operators

-----------

# Where is VHDL?
###  ModelSim

VHDL is just the language we use to describe the circuit.

We need another piece of software to simulate that circuit,
by setting different inputs and seeing how that changes the output over time.

For this class,

-----------
