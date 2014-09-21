---
layout: post
title: Containers Are The New Components
comments: true
permalink: containers-are-the-new-components
---

A few weeks ago I was trying to summarize my initial experience with containers to a friend. We know each other from the <a href="http://en.wikipedia.org/wiki/BEA_Systems">BEA Systems</a> times, back in the late 90s, and we have a similar background on middleware and distributed systems. Using that common experience, I thought that a good analogy would be to compare containers with EJBs, with a new twist on the term "container".

<i>"In a way"</i>, I told my friend, <i>"the EJB container has become the new component and the container of those components is docker and the ecosystem of packaging and runtime management tools".</i>

The analogy immediatly resonated with him, and we both draw similarities in the different evolutions of distributed systems: Tuxedo transactions, CORBA objects, Java EJBs, SOA services and now Docker containers.

One could be tempted to say that history repeats itself and these concepts were already invented some time ago. I prefer to think about it as an iterative process with incremental improvements on each iteration.

One of the stregths of this new micro-services architecture is the simplicity of the contract between the service (the container) and the container of the service (the host). Virtually any piece of software (linux software anyway), can be a component of the architecture, regardless of the programming language or the internal implementation. Compare this flexibility to the EJB specification. The EJB manifest becomes the Dockerfile, where the service author can package an arbirary collection of disparate software.

This flexibility can turn into its own <i>Achilles' heel</i>. The previous iterations were governed by steering committees and standards boards. That is not necessarily a good thing but stability used to promote adoption. It seems like the opposite case now. There is a myriad of solutions for managing the services. Still, potential users might just be waiting on the sidelines until a clear winner emerges.



