---
published: true
layout: post
title: "Initialization in C++ is Seriously Bonkers"
subtitle: "Footguns Galore"
author: Mike Lui
tags:
  - C++
---


I was recently reminded of why I think it's a bad idea to teach beginners C++.
It's a bad idea because it is an objective mess--albeit a beautiful, twisted, tragic, wondrous mess.
This is partly a follow-up on [Simon Brand's][simon-brand] article, [Initialization in C++ is bonkers][simon-brand-init],
and partly a commentary on every student who's wanted to begin their education by gazing into the abyss.
{:.lead}

Here are some common remarks I get when students find out they'll be using C:
 * *"People still use C?"*
 * *"C is stupid."*
 * *"Why are we learning C?"*
 * *"We should be learning something better like C++."* (***cue laugh track***)

Many students seem to think learning C is of little relevance (***narrator:*** *it's not*) and,
more relevant to this post, seem to think that they should instead start with C++.
Let's investigate just one of the reasons this is an absurd suggestion: ***creating a frickin' variable.***
In Simon Brand's original article, he assumed the reader was already familiar with pre-C++11 initialization
oddities.
I'll introduce some of those here and go a bit beyond, too.

Let me preface by pointing out that, although I currently work for Drexel University's Electrical and Computer Engineering department,
the thoughts and opinions in this post--and every post--are my own and ***not*** the university's.
The classes I normally assist/instruct are part an engineering curriculum and not computer science,
and thus have different needs geared more towards embedded systems and systems programming.



# Initialization in C
### Prologue

First let's look at initialization in C[^c_init], since it's similar to C++ for compatibility reasons.
This should go by fairly quick since C is so boring and simple (*ahem*).
Initialization is hammered into anyone new to the language because it acts rather differently in C than
in many newer statically typed languages, that will either default to sane values or provide 
compile time errors if used uninitialized.

```c
int main() {
    int i;
    printf("%d", i);
}
```

Any C programmer worth anything knows that this initializes `i` to an indeterminate value
(for all intents and purposes, `i` is uninitialized).
Generally, it's good practice to initialize variables *when they are defined*, e.g. `int i = 0;`,
and variables must always be initialized *before* they're used.
No matter how many times we ~~repeat, shout, scream, badger~~ gently remind students about this,
there are still those who think it gets initialized to `0` by default.

Great, let's try something else simple.

```c
int i;

int main() {
    printf("%d", i);
}
```

So this is obviously the same, right?
We have no idea what value `i` might have when we print--it could be anything.

*Nope*.

Because `i` has static storage duration, it's initialized to unsigned zero.
Why, you ask? Because the standard says so.
This has similar behavior for pointer types, which I'm not even going to address in this post.

O-kay, let's look at structs.

```c
struct A {
    int i;
};

int main() {
    struct A a;
    printf("%d", a.i);
}
```

Same deal. `a` is uninitialized.
We can see this if we compile with warnings.

```
$ gcc -Wuninitalized a.c
a.c: In function ‘main’:
a.c:9:5: warning: ‘a.i’ is used uninitialized in this function [-Wuninitialized]
     printf("%d\n", a.i);
```   

In C, we can initialize our object a few straight-forward ways.
For example:
1) by using a helper function,
2) initializing during definition, or
3) assigning some default global value.


```c
struct A {
    int i;
} const default_A = {0};

void init_A(struct A *ptr) {
    a->i = 0;
}

int main() {
    /* helper function */
    struct A a1;
    init_A(&a1);

    /* during definition;
     * initialize each member, in order... */
    struct A a2 = {0};

    /* ...or allow members to be implicitly initialized,
     * which defaults to the value it would take during
     * static initialization (i.e. 0) */
    struct A a3 = {};

    /* ...or use designated initializers if C99 or later */
    struct A a4 = {.i = 0};

    /* default value */
    struct A a5 = default_A;
}
```

That's pretty much it for C, and it's enough to cause many tricksy bugs to manifest in many student projects.
It's certainly enough to cause a minor headache deciding how to simply default everything to `0`.

# Initialization in C++
### Act 1: Our Hero's Journey Begins

If you're eager to learn all the ~~terrors~~ wonders of C++, you should first learn how to initialize your variables.
All the same *behaviors* apply for C++ as in C for the previous code, with some caveats in the *rules*
for those behaviors.
C++-specific lingo will be *italicized* to emphasize when I'm not just arbitrarily naming things
and to emphasize how many more...*features*...C++ has compared to C.
Let's start off with an easy one:

```c++
struct A {
    int i;
};

int main() {
    A a;
    std::cout << a.i << std::endl;
}
```


C++ has almost the same behavior as C here.
In C, this just creates an object of type `A` whose value could be anything.
In C++, `a` is *default initialized*[^default_init], meaning its *default constructor*[^default_constructor] is used to construct it.
Because `A` is so trivial, it has an *implicitly-defined default constructor* which does nothing
in this case. The implicitly-defined default constructor *"has exactly the same effect"* as:

```c++
struct A {
    A(){}
    int i;
}
```

To check that we're getting an uninitialized value, we can opt for a compile-time warning.
As of this post, I've found that `g++ 8.2.1` provides good warnings, while `clang++ 7.0.1`
does not for this case (with `-Wuninitialized`).
Note that optimizations are turned on to catch some extra examples where variables would be uninitialized.

```
$ g++ -Wuninitalized -O2 a.cpp
a.cpp: In function ‘int main()’:
a.cpp:9:20: warning: ‘a.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << a.i << std::endl;
```   

So in essence, this is as we'd expect coming from C.
So how do we initialize `A::i`?

### Act 2: Our Hero Stumbles

Well, we could at least use the same ways as we did in C, right?
C++ is a superset of C, after all, right? (*ahem*)

```c++
struct A {
    int i;
};

int main() {
    A a = {.i = 0};
    std::cout << a.i << std::endl;
}
```

```
$ g++ -Wuninitialized -O2 -pedantic-errors a.cpp
a.cpp: In function ‘int main()’:
a.cpp:9:12: error: C++ designated initializers only available with -std=c++2a or -std=gnu++2a [-Wpedantic]
     A a = {.i = 0};
```

Well there goes the neighborhood.
Apparently designated initializers aren't supported in C++ until C++20.
That is, the C++ standards targeted for 2020.
Yes, C++ is getting a feature 21 years after C.
Note that I've added `-pedantic-errors` to remove support for non-standard gcc extensions.

What about this?

```c++
struct A {
    int i;
};

int main() {
    A a = {0};
    std::cout << a.i << std::endl;
}
```

```
$ g++ -Wuninitialized -O2 -pedantic-errors a.cpp
```

Well at least that works.
As in C, we can also do `A a = {};` and it will have the same effect of zero-initializing `a.i`.
That's because `A` is an *aggregate type*[^agg_init].
What's an aggregate type?

In ***pre-C++11*** world: an aggregate type is (essentially) either a simple C-style array,
or a struct that looks like a simple C struct.
No access specifiers, no base classes, no user-declared constructors, no virtual functions.
An aggregate type gets *aggregate initialized*.
What's aggregate initialization?

1. Each member of the aggregate is initialized by each element of the braced list in order.
2. Each member without a corresponding element braced list will get *value initialized*[^value_init].

Great, what does that mean?
If the member is another class type with a user-provided constructor, it'll be called.
If the member is a class type without a user-provided constructor, like `A`, it'll be recursively value-initialized.
If the member is a built-in like our `int i`, then it's *zero-initialized*[^zero_init].

HooOOooOOrraay! We finally achieved a sort-of-default value of zero!  Whew.

In ***post-C++11*** world: ...we'll get to that later.

Does that seem hard to remember and confusing?
Note there's a different set of rules for each version of C++.
***It is. It's frickin' confusing and no one likes it***.
These rules are mostly in place so things act like you'd expect them to when you go to initialize something with nothing.
In practice, it's best to explicitly initialize.
I'm not picking on aggregate initialization in its own right.
I'm picking on having to partake in a goose-chase through the standard to find out precisely what happens during initialization.

### Act 3: Our Hero Journeys Into the Cave

Let's use the C++ way to initialize `A`, with **constructors**! (*triumphant music*)
We can give `A`'s member, `i`, an initial value in a *user-provided* default constructor:

```c++
struct A {
    A() : i(0) {}
    int i;
};
```

This initializes `i` in a *member initializer list*[^init_list].
A smellier way would be to set the value inside the constructor body: 

```c++
struct A {
    A() { i = 0; }
    int i;
};
```

Because the constructor body can pretty much do anything, it's better to separate initialization into
the member initializer list (technically a part of the constructor body).


{% callout info %}
In C++11 or later, we can use *default member initializers*[^default_member] (seriously, just use these when you can).
{:.mt-0}
```c++
struct A {
    int i = 0; // default member initializer, available in C++11 and later
};
```
{% endcallout %}

O-kay, now the default constructor ensures that `i` is set to 0 when any `A` is default initialized.
Finally, if we wanted to allow users of `A` to set `i`'s initial value, we could create another constructor just for that,
or alternatively mush them together using default arguments:

```c++
struct A {
    A(int i = 0) : i(i) {}
    int i;
};

int main() {
    A a1;
    A a2(1);

    std::cout << a1.i << " " << a2.i << std::endl;
}
```

```
$ g++ -pedantic-errors -Wuninitialized -O2 a.cpp
$ ./a.out
0 1
```

{% alert info %}
We can't write `A a();` to call the default constructor because it gets parsed as:
a declaration of a function, named `a`, that takes no arguments and returns an `A` object.
Why? Because someone somewhere a long time ago wanted to allow function declarations in compound statement blocks,
and now we're stuck with it.
{% endalert %}


Great! That's it. Mission accomplished. Roll credits.
You are now ready your adventures into C++ primed with your handy-dandy
C++ survival guide with instructions on initializing variables.
Turn around and be on your way!

### Act 4: Our Hero Continues Into the Blackness
We *could* stop there.
But, if we want to use the *modern* features of *modern C++*, we have to delve further.
In fact the version of g++ I've been using (8.2.1) uses `gnu++1y` by default, which equivalent to C++14 with some extra GNU extensions.
Even more, this version of g++ also fully supports C++17.
*"Does that matter?"* you might ask. Put on your fishing waders and wade with me yonder.

All versions following, and including, C++11, have this new-fangled way to initialize objects, called *list initialization*[^list_init].
Did anyone else feel a chill up their spine just now?
This is also referred to as *uniform initialization*.
There are some good reasons to use this syntax, covered [here](https://isocpp.org/wiki/faq/cpp11-language-misc#cpp11-narrowing)
and [here](https://isocpp.org/wiki/faq/cpp11-language#uniform-init).
One amusing quote from the FAQ:
> C++11 uniform initialization is not perfectly uniform, but it’s very nearly so.

List initialization uses braces (`{thing1, thing2, ...}`, called a *braced-init-list*) and looks like this:

{% highlight c++ linenos %}
#include <iostream> 
struct A {
    int i;
};
int main() {
    A a1;      // default initialization -- as before
    A a2{};    // direct-list-initialization with empty list
    A a3 = {}; // copy-list-initialization with empty list
    std::cout << a1.i << " " << a2.i << " " << a3.i << std::endl;
}
{% endhighlight %}

```
$ g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
a.cpp: In function ‘int main()’:
a.cpp:9:26: warning: ‘a1.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << a1.i << " " << a2.i << " " << a3.i « std::endl;
```

*Whoa, whoa, whoa*. Did you catch that? Only `a1.i` is uninitialized.
Clearly, list initialization works differently than just calling a constructor.  

`A a{};` produces the same behavior as `A a = {};`.
In both, `a` is initialized with an empty braced-init-list.
Also, `A a = {};` isn't called aggregate initialization anymore--now it's *copy-list-initialization* (*sigh*).
We already said that `A a;` creates an object with indeterminate value and calls the default constructor.

The following happens in lines 7/8 (remember, this is ***post-C++11***):
 1. List initialization of `A`, causes 2.
 2. *aggregate initialization* because `A` is an *aggregate type*.
 3. Because the list is empty, all members are initialized by empty lists.
    1. `int i{}` leads to value initialization which initializes `i` to 0.

What if this list isn't empty?

```c++
int main() {
    A a1{0}; 
    A a2{%raw%}{{}}{%endraw%};
    A a3{a1};
    std::cout << a1.i << " " << a2.i << " " << a3.i << std::endl;
}
```

```
$ g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
```

`a1.i` is initialized with `0`, `a2.i` is initialized with an empty list, and `a3` is copy constructed from `a1`.

Unfortunately, the definition of an aggregate has changed in every version since C++11,
although there is functionally no difference between C++17 and C++20 aggregates, so far.
Depending on which version of the C++ standard is used, something may or may not be an aggregate.
The trend is to be more permissive of what is considered an aggregate.
For example, public base classes are allowed in aggregates as of C++17, which in turn complicates the rules of aggregate initialization.
Everything is great!

How are you feeling? Do you need some water? Are your fists clenching? Maybe take a break, go outside.

### Act 5: Sanity's Requiem
What happens if `A` isn't an aggregate?

Quick recap, an aggregate is:
 * an array, or
 * a struct/class/union with
     * no private/protected members
     * no user-(provided/declared) constructors
     * no virtual functions
     * no default member initializers (in C++11, doesn't matter for later) 
     * no base classes (public bases allowed in C++17)
     * no inherited constructors (`using Base::Base;`, in C++17)

---

So not-an-aggregate could be:

{% highlight c++ linenos %}
#include <iostream>
struct A {
    A(){};
    int i;
};
int main() {
    A a{};
    std::cout << a.i << std::endl;
}
{% endhighlight %}

```
$ g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
a.cpp: In function ‘int main()’:
a.cpp:8:20: warning: ‘a.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << a.i << std::endl;
```

Here, `A` has a user-provided constructor so list initialization works differently.  
The following happens on line 8:
1. List initialization of `A`, causes 2.
2. Non-aggregate with an empty braced-init-list causes value initialization, go to 3.
3. A user-provided constructor was found, so the default constructor called which does nothing in this case.
   `a.i` is uninitialized.

---

{% callout info %}
What's a user-provided constructor anyway? 
{:.mt-0}

```c++
struct A {
    A() = default;
};
```

The above is *not* a user-provided constructor.
It's as if no constructor was declared at all and `A` is an aggregate.

```c++
struct A {
    A();
};
A::A() = default;
```
The above *is* a user-provided constructor.
It's as if we wrote `A(){}` in the body and `A` is not an aggregate.

Guess what, in C++20, the wording has changed to require aggregates to have no user-*declared* constructors 😊.
What does that mean in practice? I'm not sure! Let's carry on.
{% endcallout %}

---

What about the following:

```c++
#include <iostream>
class A {
    int i;
    friend int main();
};
int main() {
    A a{};
    std::cout << a.i << std::endl;
}
```

`A` is a class, not a struct, so `i` is private, and we had to set `main` as a friend function.
That makes `A` not an aggregate. It's just a normal class type.
That means `a.i` will be uninitialized, right?

```
g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
```

Dangit. And just when we thought we were getting the hang of this.
Turns out `a.i` will be initialized to `0`, even though it doesn't invoke aggregate initialization:
1. List initialization of `A`, causes 2.
2. Non-aggregate, class type with a default constructor, and an empty braced-init-list causes value initialization, go to 3.
3. No user-provided constructor found, so zero-initialize the object, go to 4.
4. Invoke default-initialization if the implicitly-defined default constructor is non-trivial
   (it is in this case so nothing is done).

What if we tried to use aggregate initialize:

```c++
#include <iostream>
class A {
    int i;
    friend int main();
};
int main() {
    A a = {1};
    std::cout << a.i << std::endl;
}
```

```
$ g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
a.cpp: In function ‘int main()’:
a.cpp:7:13: error: could not convert ‘{1}’ from ‘<brace-enclosed initializer list>’ to ‘A’
     A a = {1};
```

`A` is *not* an aggregate, so the following happens:
1. List initialization of `A`, causes 2.
2. Search for a matching constructor 
3. No way to convert a `0` to an `A`, compilation fails

---

One last example for good measure:

```c++
#include <iostream>
struct A {
    A(){}
    int i;
};
struct B : public A {
    int j;
};
int main() {
    B b = {};
    std::cout << b.i << " " << b.j << std::endl;
}
```

```
$ g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
a.cpp: In function ‘int main()’:
a.cpp:11:25: warning: ‘b.B::<anonymous>.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << b.i << " " << b.j << std::endl;
```

`b.j` is initialized but `b.i` is uninitialized. What's happening in this example?
I'm not sure! 🤷
All of `b`'s bases and members *should* be getting zero-initialized here.
I've asked about this on [Stack Overflow](https://stackoverflow.com/questions/54028846/why-is-a-member-not-getting-zero-initialized-in-this-example),
and as of publishing this post haven't received a sufficient answer other than a possible compiler bug.
For comparison, clang's static analyzer (not the normal compiler warnings) does not warn about uninitialized values.
Go figure.

... (*blankly stares at you*) (*stare turns to polite smile*) alright let's dive deeper!


### Act 5: The Abyss

C++11 introduced something called a `std::initializer_list`[^initializer_list].
It has its own type, which is obviously `std::initializer_list<T>`.
You can create one with a braced-init-list.
Oh by the way, a braced-init-list, used in list initialization, that has *no type*.
Make sure you don't confuse an initializer_list with list initialization or braced-init-lists!
And they are sorta related to member initializer lists and default member initializers,
in that they help initialize non-static data members, but are also quite different.
They are related but different! Easy, right?

{% highlight c++ linenos %}
struct A {
    template <typename T>
    A(std::initializer_list<T>) {}
    int i;
};

int main() {
    A a1{0};
    A a2{1, 2, 3};
    A a3{"hey", "thanks", "for", "reading!"};
    std::cout << a1.i << a2.i << a3.i << std::endl;
}
{% endhighlight %}

```
$ g++ -std=c++17 -pedantic-errors -Wuninitialized -O2 a.cpp
a.cpp: In function ‘int main()’:
a.cpp:12:21: warning: ‘a1.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << a1.i << a2.i << a3.i << std::endl;
                     ^
a.cpp:12:29: warning: ‘a2.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << a1.i << a2.i << a3.i << std::endl;
                             ^
a.cpp:12:37: warning: ‘a3.A::i’ is used uninitialized in this function [-Wuninitialized]
     std::cout << a1.i << a2.i << a3.i << std::endl;
```

O---kay. `A` has one templated constructor that takes a `std::initializer_list<T>`.
The user-provided constructor is called each time, which does nothing, so `i` remains uninitialized.
The type of `T` is deduced depending the elements in the list, and a new constructor is instantiated depending on the type.
* So in line 8, `{0}` is deduced as a `std::initializer_list<int>` with one element, `0`.
* In line 9, `{1, 2, 3}` is deduced as a `std::initializer_list<int>` with three elements.
* In line 10, the braced-init-list is deduced as a `std::initializer_list<const char*>` with 4 elements.

{% alert info %}
`A a{}` will produce an error because a type cannot be deduced.
We would have to write `A a{std::initializer_list<int>{}}`, for example.
Or, we could exactly specify the constructor as in `A(std::initializer_list<int>){}`.
{% endalert %}

`std::initializer_list` acts kinda like a typical STL container,
but it only has three member functions: `size`, `begin`, and `end`.
`begin` and `end` return iterators you can dereference, increment, and compare normally.
This is useful when you want to initialize an object with varying length lists:

```c++
#include <vector>
#include <string>
int main() {
    std::vector<int> v_1_int{5};
    std::vector<int> v_5_ints(5);
    std::vector<std::string> v_strs = {"neato!", "blammo!", "whammo!", "egh"};
}
```

`vector` has a constructor that takes a `std::initializer_list<T>`, so we can easily initialize vectors as shown above. 
{% alert info %}
`v_1_int` is a vector created from its constructor taking a `std::initializer_list<int> init` with one element, `5`.  
`v_5_ints` is a vector created from its constructor taking a **`size_t count`**, which initializes a vector of count (`5`) elements and value-initializes them (all set to `0` in this case).
{% endalert %}


Okie--dokie, one last example:


{% highlight c++ linenos %}
#include <iostream>
struct A {
    A(std::initializer_list<int> l) : i(2) {}
    A(int i = 1) : i(i) {}
    int i;
};
int main() {
    A a1;
    A a2{};
    A a3(3);
    A a4 = {5};
    A a5{4, 3, 2};
    std::cout << a1.i << " "
              << a2.i << " "
              << a3.i << " "
              << a4.i << " "
              << a5.i << std::endl;
}
{% endhighlight %}

At first glance, this isn't too complicated.
We have two constructors, one that takes a `std::initializer_list<int>` and another with default arguments taking an `int`.
Before you look below at the output, try to figure out what will be the value for each `i`.

Thought about it...? Let's see what we get.
{:.pb-5}


```
$ g++ -std=c++11 -pedantic-errors -Wuninitialized -O2 a.cpp
$ ./a.out
1 1 3 2 2
```

`a1` should have been easy. This is simple default initialization, which chooses the default constructor using its default arguments.
`a2` uses list initialization with an empty list.
Because `A` has a default constructor (with default arguments), value initialization occurs which just calls that constructor.
If `A` didn't have that constructor, then the constructor on line 3 would be called with an empty list.
`a3` uses parenthesis, not a braced-init-list, so the overload resolution matches `3` with the constructor taking an `int`.
`a4` uses list initialization, which overload resolution will more favorably match with a constructor taking a `std::initializer_list`.
`a5` obviously can't match against a single `int`, so the same constructor as `a4` is used.


### Epilogue
Hopefully you've realized this post is (*mostly*) tongue-in-cheek and hopefully a bit informative, too.
Many of the peculiarities described in this post can be ignored and the language will act as you'd expect
if you remember to initialize your variables before use and initialize your data members during construction.
Knowing all of the corner cases of C++ is not necessary to write competent code, and you will otherwise learn
common pitfalls and idioms along the way. 

The point I've hopefully gotten across is that C++ is a big, crusty language (for many historical reasons).
This entire post was a rabbit hole on initialization rules.
*Just initializing variables*.
And we didn't even cover all of it.
This post briefly covers 5 types of initialization.
Simon mentions in his [original post][simon-brand-init] that he found 18 types of initialization.

C++ is not a language I'd want to teach beginners.
At no point in this post was there room for systems programming concepts, discourse on programming paradigms,
computational-oriented problem solving methodologies, or fundamental algorithms.
If you are interested in C++ then feel free to take a class specifically on C++,
but know that the class will probably be specifically on learning C++.

C is a great, focused, fast, widely-supported, and widely-used language for solving problems across a variety of domains.
And it doesn't have at least 18 types of initialization.

[simon-brand]: https://blog.tartanllama.xyz/
[simon-brand-init]: https://blog.tartanllama.xyz/initialization-is-bonkers/

[^c_init]: [C initialization](https://en.cppreference.com/w/c/language/initialization)
[^default_init]: [Default initialization](https://en.cppreference.com/w/cpp/language/default_initialization)
[^default_constructor]: [Default constructors](https://en.cppreference.com/w/cpp/language/default_constructor)
[^list_init]: [List initialization](https://en.cppreference.com/w/cpp/language/list_initialization)
[^agg_init]: [Aggregate initialization](https://en.cppreference.com/w/cpp/language/aggregate_initialization)
[^value_init]: [Value initialization](https://en.cppreference.com/w/cpp/language/value_initialization)
[^zero_init]: [Zero initialization](https://en.cppreference.com/w/cpp/language/zero_initialization)
[^init_list]: [Member initializer lists](https://en.cppreference.com/w/cpp/language/initializer_list)
[^default_member]: [Default member initializers](https://en.cppreference.com/w/cpp/language/data_members#Member_initialization)
[^initializer_list]: [`std::initializer_list`](https://en.cppreference.com/w/cpp/utility/initializer_list)
