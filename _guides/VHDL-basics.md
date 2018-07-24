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
It literally stands for: **V**HSIC (yes another acronym--don't sweat it) **Hardware Description Language**.
VHDL targets digital circuits in contrast to analog circuits.
*Digital* circuits consider logical properties like 1's and 0's, Yes's and No's, while
*analog* circuits consider electrical properties like impedance, capacitance, et al.
This is a generalization but will hold true as far as an introductory course is concerned.

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

{% alert info %}
`<=` is an assignment operator in VHDL. It is *not* `less than or equal to` like in some other languages.
{% endalert %}

Although the syntax is a bit clunky, you can see how we're just defining an inverter; a `NOT` gate.
First, we declare the inputs and outputs of our circuit block.
Then, we describe how the input is transformed into the output.
We're describing the following equation:

$$
\begin{align*}
out_1 = inverter(in_1) = {in_1}\prime
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
    If you need to know something specific please [find][searchvhdl] a more [complete reference][vhdlreference].

[ece200]: http://catalog.drexel.edu/coursedescriptions/quarter/undergrad/ece/
[searchvhdl]: https://duckduckgo.com/?q=vhdl+reference
[vhdlreference]: https://ieeexplore.ieee.org/document/4772740/

-----------

# Why is VHDL?

Why would we want to model digital circuits?
It's easier to understand, modify, simulate, and test our designs by modeling our circuits in VHDL.
VHDL also provides a common format starting from initial prototyping and eventually ending at design for manufacturing.
Most importantly, it allows us to treat a design as a black box, so we can build up more complex and powerful circuit designs.

-----------

# How is VHDL?

Many of you will have been exposed to a programming language at this point.
VHDL and other HDLs can be thought of as a programming language for digital circuits:

| HDLs | Traditional Programming Languages                                    |
|:-|:-
| VHDL, Verilog, SystemC, Bluespec | Python, Matlab, C, Javascript, R, Racket |
|---
| describes digital circuits | describes a set of steps for the computer to execute |
|---
| build up complex circuit behavior from smaller simple circuits | build up complex program behavior from smaller simpler subroutines |
|---
| building blocks from boolean algebra | building blocks from arithmetic |
{: .table .table-hover}

{% callout primary %}
#### Ordering in VHDL
Before we move on, let's distinguish one more difference between between traditional programming and HDLs.
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

If we read the above example like a sequential program,
it looks like `between` is being assigned to `b` before `between` has any value!
We don't set `between` until the next line.
However, when we go to run the circuit, we'll see `b` and `c` will have the same value at the same time.
This is because we're just connecting *signals* together.

![fanout](/img/posts/fanout2.png){: width="100%"}

When we simulate this circuit all of our 1's and 0's flow through the circuit in a real-time(ish) way.
Eventually you'll see how to modeling sequential statements in VHDL.

{% endcallout %}


#### Designing a Thing

Here we'll learn basic VHDL by example.

Let's try to make a basic switch that selects between **two** signals.
We can do this because a single switch has **two** states: *on* and *off*.
Easy-peasy. 

If the switch is *off*, then the first signal is selected.  
If the switch is *on*, then the second signal is selected.


| s0 | s1 | select | output |
|-|-|-|
| 0 | 0 | 0 | 0 |
|---
| 0 | 0 | 1 | 0 |
|---
| 0 | 1 | 0 | 0 |
|---
| 0 | 1 | 1 | 1 |
|---
| 1 | 0 | 0 | 1 |
|---
| 1 | 0 | 1 | 0 |
|---
| 1 | 1 | 0 | 1 |
|---
| 1 | 1 | 1 | 1 |
{: .table .table-sm .table-bordered .w-50 .mx-auto .text-center}

$$
\begin{align*}
output = (select * s1) + (select\prime * s0)
\end{align*}
$$


![mux](/img/posts/mux2.png){:width="100%"}

1. The first step is to sketch out a schematic of a thing:


   Our thing is only using basic boolean gates, 

2. Next we'll give names to all the wires so we can reference them later.

{% include code-title.html contents="a_thing.vhd" %}
{% highlight vhdl linenos %}
-- Comments start with '--'
-- Inputs and Outputs of a thing!
ENTITY mux_2x1 IS
    PORT ( s0  : IN BIT;
           s1  : IN BIT;
           sel : IN BIT;
           output : OUT BIT
         );
END mux_2x1;


-- The inside guts of a thing!
ARCHITECTURE df OF mux_2x1 IS
    SIGNAL sel_not;
BEGIN
    s0_not <= NOT s0;
    s2 <= sel_not AND s0;
    s3 <= sel AND s1;
    output <= s2 OR s3;
END df;
{% endhighlight %}

Let's unpack this one piece at a time.

{% accordion a-thing %}

{% collapse Keywords, Identifiers, and Operators %}
In the above example, the highlighted code differentiates between:
 - *keywords* like `ENTITY`, `ARCHITECTURE`, and `BEGIN` which denote the **structure** of our code.
 - *identifiers* like `s1`, `a`, `a_thing`, and `df`, which are just **names** we've chosen for different parts of our design.
 - *operators* like `<=`, `AND`, et al, which can **create and set values** referenced by identifiers.

{% include note.html content="VHDL is case-insensitive.
That means it doesn't matter if you capitalize letters or not: `a_thing`, `A_THING`, `a_ThINg`, etc all refer to the same identifier.
In the examples shown, I made keywords ALL-CAPS and identifiers lower-case, to differentiate them.
In your code, you can choose whichever you're comfortable with.
Just remember to stay consistent."
%}
{% endcollapse %}

{% collapse Modules %}
We've created a *design entity* (commonly referred to as a *module*).  
`3.1` in the IEEE Standard VHDL Language Reference Manual:
 > The design entity is the primary hardware abstraction in VHDL.
 > It represents a portion of a hardware design that has well-defined
 > inputs and outputs and performs a well-defined function.
 > A  design entity may represent an entire system, a subsystem, a board,
 > a chip, a macro-cell, a logic gate, or any level of abstraction in-between.

To reduce confusion with the `ENTITY` keyword, we'll call this a *module* from now on.
Basically, a module is a full description of a thing. 
It describes:
 - The `ENTITY` -- the inputs and outputs; our interface to `a_thing`
 - The `ARCHITECTURE` -- the insides of our circuit; what happens to the inputs to create the output

{% include note.html content="A module **is not** just a VHDL file.
A module (the `ENTITY` and `ARCHITECTURE`) could be spread across one or more files.
Conversely, a single file might have multiple modules." %}

{% comment %}
{% include note.html content="Semicolons are usually at the *end* of declarations.
For example, at the ends of: the entity, the ports, the architecture, and then also the end of the assignment statements."
%}
{% endcomment %}
{% endcollapse %}

{% collapse Signals %}
Signals are the basic *data values* in VHDL.
We **don't** use the term *variable* because it is reserved for sequential processes which won't be covered in this guide.

Because we're modeling digital circuits, signals can be thought of as the wires connecting
components together. On `line 14` of our `a_thing`, we declare the existence of four signals.
These are the internal wires in our schematic:

We assign signals with the `<=` operator. This also informs us of the *direction* of our data.
For example, `s1 <= s2` would move data as:
{% endcollapse %}

{% collapse Inputs and Outputs %}
The `ENTITY` describes the interface to our *thing*.
The *inputs and outputs*, the wires we can *set* and *read* from, is described in the `ENTITY`.
- Inputs can only be read and cannot be assigned: `input <= a_signal` will cause an error.
- Outputs can only be assigned and cannot be read: `a_signal <= output` will also cause an error.

These are referred to as *ports*.
If we're designing something that takes inputs from the outside world, does something with them,
and then delivers the outputs back to the outside world, then we need to declare ports in our `ENTITY`:

``` vhdl
ENTITY another_thing IS
   PORT ( from_the_outside_world    : IN BIT;
          back_to_the_outside_world : OUT BIT );
END another_thing;
```

You can see that each port is given 1) a name, 2) a direction, and 3) a type.
For example: `a : IN BIT;` is named *a*, is an *input* from the outside world, and is a single *bit*.

{% include note.html content="Ports are signals, too" %}
{% endcollapse %}

{% collapse Architecture %}
The `ARCHITECTURE` structure describes what goes on inside our schematic.
On `line 13` we start by giving our `ARCHITECTURE` a name: `df`, and declaring that this is the architecture `OF a_thing`.

#### Naming
The name `df` is shorthand for *dataflow*.
Dataflow is the name of the *style* used.
In the coming weeks, we'll also discuss *behavioral (behav)* and *structural (struct)* styles.
We could have named our architecture `GooGooGaGa` if we wanted to, but it's clearer to choose names based on the architecture style.
Note that there can be overlap between styles and there is not always a clean distinction.

In dataflow styles, the architecture is just a set of signal assignments and equations.
We are just describing how data *flows*.
Once you see examples of behavioral and structural styles, the distinction will be more clear.

#### Declarations
`Line 14` declares any extra signals or *components*.

#### Statements
The real work happens between lines `16` and `25`.

{% endcollapse %}

{% endaccordion %}


This is not an exhaustive explanation of building circuits in VHDL.
In the coming week,s you will learn how to compose simple circuits to build more complex circuits that can do math like $$ (4+5) $$.

-----------

# Where is VHDL?

VHDL is the language we use to describe the circuit.
We need another piece of software to actually simulate that circuit and observe its functionality.
In this class, we'll use ModelSim both for coding and simulating.
If you want to use ModelSim at home, you can download a version from the [ModelSim website][modelsim].

[modelsim]: https://www.mentor.com/company/higher_ed/modelsim-student-edition

-----------


