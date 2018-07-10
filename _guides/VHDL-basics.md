---
published: true
layout: post
title: "VHDL Student Primer"
subtitle: "Important Concepts"
background: /img/The-Simpsons-Season-23-Episode-11-25-6c0b.jpg
date: 2018-07-07T00:00:00.000Z
author: Mike Lui
---

{% include danger.html content="Incomplete: testing GitHub webserver" %}

# What is VHDL?

You're taking the **Digital Logic** class[^1] and figure you'll be doing some `beep boop bop` 🤖 binary things.
You'd be right.
In class, you'll learn boolean logic theory.
With the VHDL labs, you'll see how that theory can be used to make something more concrete.

VHDL is a programming language to describe circuits.
It literally stands for: **V**HSIC (another acronym 🙄) **Hardware Description Language**.
VHDL targets digital circuits in contrast to analog circuits.
While *analog* circuits consider electrical properties like impedance, capacitance, et al,
*digital* circuits consider logical properties; 1's and 0's; Yes's and No's.

Here's a taste:

``` vhdl
ENTITY inverter IS
    PORT ( in1 : IN BIT; out1 : OUT BIT );
END inverter;

ARCHITECTURE df OF inverter IS
BEGIN
    out1 <= NOT in1;
END df;
```

{% include note.html content="`<=` is an assignment operator in VHDL; it isn't *less than or equal to*." %}

Although the syntax is a bit clunky, you can see how we're just defining an inverter; a `NOT` gate.
First, we declare the inputs and outputs of our circuit block.
Then, we describe how the input is transformed into the output.
We're describing the following equation:

$$
\begin{align*}
inverter(in_1) = {in_1}'
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
    This is **not** meant to be a full reference. I'm also very loose with my language throughout this document because of the target audience.
    If you need to know something specific please [find a more complete reference][searchvhdl].

[ece200]: http://catalog.drexel.edu/coursedescriptions/quarter/undergrad/ece/
[searchvhdl]: https://duckduckgo.com/?q=vhdl+reference

-----------

# Why is VHDL?

Why would we want to model digital circuits?
It's easier to understand, modify, simulate, and test our designs by modeling our circuits in VHDL.
VHDL also provides a common format starting from initial prototyping and eventually ending at design for manufacturing.

Let's use the following circuit diagram for the rest of this post:

![a_thing](/img/posts/a_thing.png){:width="100%"}

It's much easier to pass around a standardized formal description of this ***thing*** than just its figure (its *schematic*).

-----------

# How is VHDL?

Many of you will have been exposed to a programming language at this point.
VHDL and other HDLs can be thought of as a programming language for digital circuits:

<table class="table table-hover">
  <thead>
    <tr>
      <th scope="col">HDLs</th>
      <th scope="col">Traditional Programming Languages</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>VHDL, Verilog, SystemC, Bluespec</td>
      <td>Python, Matlab, C, Javascript, R, Racket</td>
    </tr>
    <tr>
      <td>describes digital circuits</td>
      <td>describes a set of steps for the computer to execute</td>
    </tr>
    <tr>
      <td>build up complex circuit behavior from smaller simple circuits</td>
      <td>build up complex program behavior from smaller simpler subroutines</td>
    </tr>
    <tr>
      <td>building blocks from boolean algebra</td>
      <td>building blocks from arithmetic</td>
    </tr>
  </tbody>
</table>

{% callout info %}
#### Time in VHDL
Before we move on, we have to distinguish one more difference between between traditional programming and HDLs.
Traditional programming languages are based on the idea of *computation sequences*;
in other words, steps are executed one after the other in the order they appear.
For example, imperative languages guarantee that each statement happens sequentially,
so we can set data in one step and read it back afterwards.

``` python
# pseudo-code
a = 5
a.increment()
a  # a == 6
```

In VHDL, we model a circuit, so data just propagates through wires.

``` vhdl
ENTITY pass_through IS
    PORT ( a    : IN BIT; 
           b, c : OUT BIT);
END pass_through;

ARCHITECTURE df OF pass_through IS
    SIGNAL between : BIT;
BEGIN
    -- b and between are set
    -- at the same time!
    b <= between;
    between <= a;
    c <= between
END df;
```

{% include danger.html content="TODO schematic of pass_through example" %}

If we read the above example like a sequential program,
it looks like `between` is being assigned to `b` before `between` has any value!
We don't set `between` until the next line.
However, when we go to run the circuit, we'll see `b` and `c` will have the same value at the same time.
This is because we're just connecting *signals* together, and when we simulate this circuit all of our
1's and 0's flow through the circuit in a real-time(ish) way.
In later labs, you'll learn how sequential statements are implemented in VHDL.
{% endcallout %}


#### Back to our `Thing`

Remember the **thing** I drew before?
Let's describe it with VHDL.

{% include code-title.html contents="a_thing.vhd" %}
{% highlight vhdl linenos %}
-- Comments start with '--'
-- Inputs and Outputs of a thing!
ENTITY a_thing IS
    PORT ( a : IN BIT;
           b : IN BIT;
           c : OUT BIT;
           d : OUT BIT
         );
END a_thing;


-- The inside guts of a thing!
ARCHITECTURE df OF a_thing IS
    SIGNAL s1, s2 : BIT;
BEGIN
    s1 <= a AND b; -- Assign/Map c to the result of
                   -- the built-in 'AND' operation

    s2 <= a XOR b; -- Assign/Map d to the result of
                   -- the built-in 'XOR' operation

    c <= s1; -- Assign/Map output c to s1
    d <= s2; -- Assign/Map output d to s2
END df;
{% endhighlight %}

Let's unpack this one piece at a time.

{% accordion a-thing %}

{% collapse Keywords and Identifiers %}
In the above example, the highlighted code differentiates between:
 - *keywords* like `ENTITY`, `ARCHITECTURE`, and `BEGIN` which denote the structure of our code.
 - *identifiers* like `s1`, `a`, `a_thing`, and `df`, which are just names we've chosen for different values.
 - *operators* like `<=`, `AND`, et al, which can modify values held by identifiers.

{% include note.html content="VHDL is case-insensitive.
That means it doesn't matter if you capitalize letters or not: `a_thing`, `A_THING`, `a_ThINg`, etc all refer to the same identifier.
In the examples shown, I made keywords ALL-CAPS and identifiers lower-case, to differentiate them.
In your code, you can choose whichever you're comfortable with.
Just remember to stay consistent."
%}
{% endcollapse %}

{% collapse Program Structure %}
We have what's called a VHDL ***module***.
A module is a full description of a thing. 
It describes:
 - The `ENTITY` -- the inputs and outputs; our interface to *a_thing*
 - The `ARCHITECTURE` -- how the inputs get transformed into the output

A module **is not** a VHDL file.
A module could be spread across one or more files.
Conversely, a single file might have multiple modules.

**Entities** declare the inputs and outputs with the `PORT` structure.

{% include note.html content="Semicolons are usually at the *end* of declarations.
For example, at the ends of: the entity, the ports, the architecture, and then also the end of the assignment statements."
%}
{% endcollapse %}

{% collapse Inputs and Outputs %}
The *interface* to our thing, the *inputs and outputs*, the wires we can *set* and *read* from, is described in the `ENTITY`.
In the electrical engineering domain, these are referred to as *ports*Because the terminology is to refer to inputs.
Inputs can only be read and cannot be assigned. Outputs can only be assigned and cannot be read.

You can see that we each port is assigned: 1) a name, 2) a direction, and 3) a *type*.
For example: `a : IN BIT;` is named *a*, is an *input*, and is a single *bit*.
{% endcollapse %}

{% collapse Operators %}
something
{% endcollapse %}

{% endaccordion %}


#### More things

This is not an exhaustive explanation of building circuits in VHDL.
You'll learn how to compose simple circuits to build more complex circuits that can do math like $$ (4+5) $$ in the coming weeks.

-----------

# Where is VHDL?

VHDL is the language we use to describe the circuit.
We need another piece of software to actually simulate that circuit and observe its functionality.
In this class, we'll use ModelSim both for coding and simulating.
If you want to use ModelSim at home, you can download a version from the [ModelSim website][modelsim].

[modelsim]: https://www.mentor.com/company/higher_ed/modelsim-student-edition

-----------


