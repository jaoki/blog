---
authors:
- jaoki
categories:
- HDFS
- Kerberos
- Ambari
date: 2016-04-18T17:30:56-07:00
draft: true
title: Kerberos and HDFS
short: |
  Do you know what _"RULE:\[2:$1@$0](dn@EXAMPLE.COM)s/.*/hdfs/"_ means? This is not mojibake. This is part of HDFS configuration, and it looks intimidating (at least it did to me). This blog post explains what it really means and how kerberos configuration works with HDFS in detail.
---

## The Question
This blog post explains basics of kerberos configuration for HDFS. But let me ask you a question here first, and I will be explaining the answer step by step and you be a bit more knowledgable of the security configuration at the end.

---
_Can you explain under what setting a user foo on host1.com can access to files on HDFS below_

```
[pivotal@ip-10-32-37-53 ~]$ hadoop fs -ls /user 
drwxr-x--- - jennifer smith 0 2016-02-13 00:29 /user/jennifer 
```

_with a kerberos principal john/doe@EXMAPLE.COM just because a linux user called jane on host2.com belongs to a group called smith?_

---


Is it pretty twisting?

Let me draw a diagram.

{{< responsive-figure src="/images/kerberos-and-hdfs-question-diagram.png" class="left" >}}

From next section, we are going to find out the answer step by step.


## foo and John Doe, how can they be associated? (keytab)

{{< responsive-figure src="/images/kerberos-and-hdfs-foo-and-john-doe.png" class="left" >}}

We go step by step. First, let's see how foo can be john/doe

Here, we are going to use keytab. _xst_ or _ktadd_ are the command to create keytab.

~~~bash
xst -norandkey -k /etc/security/keytabs/john.doe.keytab john/doe@PIVOTAL.IO
~~~

_kinit_ is the command to consume keytab

~~~bash
su - foo # You are foo
kinit -kt /etc/security/keytabs/john.doe.keytab john/doe@PIVOTAL.IO # Now you are john/doe@PIVOTAL.IO
~~~

Done.

We keep finding how each association is established this way. Next...

## John to Jane (auth_to_local)

{{< responsive-figure src="/images/kerberos-and-hdfs-auth_to_local.png" class="left" >}}

User foo has kinit-ed john/doe@PIVOTAL.IO. Now it associates with jane. Simple "jane", using some concept called _auth_to_local_.

What does it mean?

* Map to a simple user id like jane, instead of jone/doe@PIVOTAL.IO
* Can bring a concept of Grouping using Linux’s /etc/groups (Is it? Will talk about this later)

### What is auth_to_local?

_auth_to_local_ is a configuration that maps one type of string to another. Something look like this

{{< responsive-figure src="/images/kerberos-and-hdfs-auth_to_local-setting-on-ambari.png" class="left" >}}
(Screenshot from Ambari and stored in core-site.xml)

And yes, that's the intimidiating and mysterius string I raised at the top of this blog post. Let's learn how that works (and hopefully it is less mysterious :) )

### How auth_to_local translation occurs

```
RULE:[2:$1@$0](dn@EXAMPLE.COM)s/.*/hdfs/
```

It consists 3 parts.

| Part            | Name                    |
| --------------  | ----------------------- | 
| [2:$1@$0]       | Principal Translation   |
| dn@EXAMPLE.COM  | Acceptance Filter       |
| s/.*/hdfs/      | Short Name Substitution 


### Principal Translation

TODO

### Acceptance Filter

This is to filter results of Principal Translation. 

When Principal Translation result is “dn@EXAMPLE.COM”,

| Filter is       | Match?       |
| --------------  | ------------ | 
| dn@EXAMPLE.COM  | Matches      |
| nn@EXAMPLE.COM  | Not match    |
| [rn]m@.*        | Not match    |
| [dn]n@.*        | Matches      |

It is pretty flexible. You can use regular expression too.


### Short Name Substitution
If the string is matched, then it make it shorer name using sed’s replace expression

When Principal translation result is _"dn@EXAMPLE.COM"_ and Short Name Substitution is _"s/.*/hdfs/"_ the result is _"hdfs"_, as in

```bash
> echo "dn@EXAMPLE.COM" | sed s/.*/hdfs/
hdfs
```





_copied from [the README](https://github.com/pivotal/blog#writing-a-good-post)..._

### Keep it technical.

People want to to be educated and enlightened.  Our audience are engineers, so the way to reach them is through code.  The more code samples, the better.

### Nobody likes a wall of text.


Use headers to break up your text.  Each image you add to your post increases its XP by 100.  Diagrams, screen shots, or humorous "meme" (_|memā|_) gifs...  They all add color.  If you don't have [OmniGraffle](https://www.omnigroup.com/omnigraffle), then submit an ask ticket.  There's no excuse for monotony.

### Your 10th grade teacher was right.

Make use of the hamburger technique.  Your audience doesn't have a lot of time.  Tell them what you're going to write, write it, and then tell them what you've written.  Spend time on your opening.  Make it click.

### Pair all the time.

We do everything as a team, and this is no different.  Get feedback from your friends and coworkers.  Show them the post on the staging site, and ask them to tear it apart.

### Make it pretty.

Pivotal-ui comes with a bunch of nice helpers.  Make use of them.  Check out the example styles below:

---

# Header 1 

Don't use this, since it looks like a main title.

## Header 2

### Header 3

#### Header 4

##### Header 5

###### Header 6


{{< responsive-figure src="/images/pairing.jpg" class="left" >}}

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

~~~ruby
instance = Class.new("foo")
~~~

| Header 1        | Header 2  | ...        |
| --------------  | --------- | ---------: |
| SSH (22)        | TCP (6)   | 22         |
| HTTP (80)       | TCP (6)   | 80         |
| HTTPS (443)     | TCP (6)   | 443        |
| Custom TCP Rule | TCP (6)   | 2222       |
| Custom TCP Rule | TCP (6)   | 6868       |

{{< responsive-figure src="/images/pairing.jpg" >}}

