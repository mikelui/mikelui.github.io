---
published: false
layout: post
title: "VHDL Quickstart Guide"
subtitle: "Important Concepts"
date: 2018-07-07T00:00:00.000Z
author: Mike Lui
---

The introductory Digital Design and VHDL class I've had to TA attracts students
with a wide variety of backgrounds, so I've decided to make my own quickstart guide
since the disseminated tutorials and labs can be dry.

# Why are we using VHDL?

So you're taking the **Digital Logic** class and imagine 

# So what is it used for?

# Cool.

![Cool](https://i.imgflip.com/1oq3ej.jpg)

# But how do I make these things?

Just like any other programming language.
But, instead of describing a series of steps for the computer to execute,
in VHDL you describe how a circuit looks.

Remember the **thing** I drew before?
Let's describe how that looks with VHDL.

{% highlight vhdl linenos %}
-- Inputs and Outputs of a thing!
ENTITY a_thing IS
    PORT ( A : in bit;
           B : in bit;
           C : out bit
         );
END a_thing;

-- The insides of a thing!
ARCHITECTURE behav OF a_thing IS
BEGIN
    C <= A and B; -- Assign C to the result of the built-in 'and'
END behav;
{% endhighlight %}

There's a few things to unpack here.

 - First, we have what's called a VHDL *module*.
A module is just something.
 - Second


# Trivia

This language looks pretty wonky.