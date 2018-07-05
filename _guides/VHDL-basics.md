---
published: true
layout: post
title: "VHDL Student Primer"
subtitle: "Important Concepts"
date: 2018-07-07T00:00:00.000Z
author: Mike Lui
---

The introductory digital design and VHDL class I've had to TA ([ECE-200][ece200]) attracts students
with a wide variety of backgrounds.
While some students learn just fine with the provided tutorials and labs,
others can be turned off by them.
Even then, students tend to miss some fundamental concepts when going through the
motions of the labs.

As such, I've decided to provide a quickstart guide with a slightly different flavor.

[ece200]: http://catalog.drexel.edu/coursedescriptions/quarter/undergrad/ece/

-----------

# Why are we using VHDL?

So you're taking the **Digital Logic** class and figure you'll be doing some `beep boop bop` 🤖 binary things.
You'd be right.
In class, you'll learn boolean logic theory.
With the VHDL labs, you'll see how that theory can be used to make something more concrete.

# So what is it used for?

Modeling digital circuits!
Digital circuits are different than analog circuits.
Generally,
 - Analog circuits consider electrical properties like impedance, capacitance, et al.
 - Digital circuits consider logical properties. 1's and 0's. Yes's and No's.

#### Why would we want to model digital circuits?

Remember circuits are a physical thing.
and it's usually easier and cheaper simulate circuits than
to go through the process of building them 

![a_thing](/img/posts/a_thing.png){:width="100%"}

{::comment}
# Cool.
![Cool](https://i.imgflip.com/1oq3ej.jpg){:width="100%"}
{:/comment}

-----------

# But how do I make these things?

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
 - The **`ENTITY`** -- the inputs and outputs; our interface to `a_thing`
 - The **`ARCHITECTURE`** -- how the inputs get transformed into the output

A module **is not** a VHDL file.
A module could be spread across one or more files, and a single file might have multiple modules.

#### 2) Syntax

Keywords, Identifiers, operators

-----------

# ModelSim

VHDL is just the language we use to describe the circuit.

We need another piece of software to simulate that circuit,
by setting different inputs and seeing how that changes the output over time.

For this class,

# Syntax Reference

Let's look at a stripped down VHDL module.

{% highlight vhdl linenos %}
ENTITY entity_identifier IS
    PORT (port_identifier_1 : in bit; port_identifier_2 : out bit);
END <entity_identifier>;

ARCHITECTURE architecture_identifier OF entity_identifier IS
BEGIN
    signal_identifier <= expression;
END architecture_identifier;
{% endhighlight %}

