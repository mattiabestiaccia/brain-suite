# Dimensions Guide

Reference file for the brain-explorer agent. Defines the 6 built-in dimensions, their purpose, key questions, exploration modes, and relationships.

## Overview

Brain Suite organizes idea exploration into 6 dimensions. Each dimension is a lens on the same idea — together they build a complete picture. Dimensions are not phases or steps. The user can explore them in any order, revisit any dimension, and go as deep or shallow as they want.

The explorer's job is to guide thorough exploration of each dimension while keeping the conversation natural and building on what has been learned in other dimensions.

## The 6 Dimensions

### Product

**Purpose:** Understand what you are building and why it matters.

**Default mode:** Creative (divergent thinking, expand before narrowing)

**Key questions:**
- What pain point does this solve, and how severe is it?
- What does the simplest useful version look like?
- What makes this different from everything else out there?
- What are the must-have features vs nice-to-haves?
- How should it feel to use this? What is the experience vision?
- What assumptions must be true for this product to work?
- What is explicitly out of scope for v1?

**Good output looks like:** A crisp problem statement, a clear solution concept with prioritized features, honest differentiation, and acknowledged risks/assumptions.

**Common pitfalls:** Jumping to features without defining the problem. Listing every possible feature instead of prioritizing. Describing tech instead of user experience. Ignoring assumptions.

### Tech

**Purpose:** Understand how to build it and what technical constraints shape the product.

**Default mode:** Socratic (surface assumptions about technical choices)

**Key questions:**
- What is the high-level architecture? What are the major components?
- What tech stack and why? What alternatives were considered?
- What should you build vs buy/use off-the-shelf?
- What are the hard technical constraints (performance, scale, security)?
- What is the MVP build strategy? What can you defer?
- Where are the technical unknowns or complexity hotspots?

**Good output looks like:** Architecture overview with rationale for key choices, honest build-vs-buy assessment, identified technical risks with mitigation ideas.

**Common pitfalls:** Over-engineering for scale you do not have. Choosing tech because it is exciting, not because it fits. Not considering operational complexity. Ignoring security until later.

### Market

**Purpose:** Understand who you are selling to and how to reach them.

**Default mode:** Challenger (stress-test market assumptions, push back on optimism)

**Key questions:**
- Who is the target market? How big is it and is it growing?
- What market trends work in your favor or against you?
- How will you reach your first 100 users? First 1000?
- What is your positioning — how are you different in the buyer's mind?
- What is the pricing strategy and willingness to pay?
- What market risks could kill this? Timing, regulation, saturation?

**Good output looks like:** Defined target segment with size estimate and evidence, realistic go-to-market plan, pricing rationale with willingness-to-pay reasoning, honest market risk assessment.

**Common pitfalls:** TAM/SAM/SOM fantasies without bottom-up validation. "If we get just 1% of the market..." reasoning. No plan for initial traction. Pricing pulled from thin air.

### Business

**Purpose:** Understand how the business works financially and operationally.

**Default mode:** Socratic (discover the business model through questioning)

**Key questions:**
- How does money flow in? What are people paying for?
- What does the cost structure look like? Fixed vs variable costs?
- What is the one metric that tells you this is working?
- What drives growth? Virality, content, sales, partnerships?
- What are the business risks? Cash flow, dependencies, single points of failure?

**Good output looks like:** Clear revenue model with unit economics reasoning, identified cost drivers, defined north star metric with leading indicators, growth strategy, honest risk assessment.

**Common pitfalls:** Revenue projections without cost awareness. Vanity metrics as north star. Growth strategy that requires resources you do not have. Ignoring cash flow timing.

### Competitors

**Purpose:** Understand the competitive landscape honestly.

**Default mode:** Challenger (prevent wishful thinking about competitive position)

**Key questions:**
- Who are the direct competitors? What do they do well?
- What indirect competitors or substitutes exist? How do people solve this today?
- What is your actual competitive advantage? Is it defensible?
- Who could copy you and how fast?
- How are you positioned differently in one sentence?

**Good output looks like:** Honest assessment of 3-5 competitors with strengths AND weaknesses (not just weaknesses), identified substitutes, realistic defensibility assessment, clear positioning statement.

**Common pitfalls:** "We have no competitors" (you always do — the status quo is a competitor). Only listing competitor weaknesses. Claiming defensibility from features (features are copyable). Confusing "first mover" with "advantage."

### Users

**Purpose:** Understand who uses this and what their life looks like.

**Default mode:** Socratic (build empathy and understanding through discovery)

**Key questions:**
- Who is the primary user? Describe them specifically.
- What jobs are they trying to do? (Functional, emotional, social)
- How do they solve this problem today? What is painful about that?
- What does their journey look like from discovery to regular use?
- How will you validate these assumptions before building?

**Good output looks like:** Specific persona (not generic), clear jobs-to-be-done with all three types, mapped current alternatives with pain points, realistic user journey, concrete validation plan.

**Common pitfalls:** Vague personas ("tech-savvy millennials"). Only functional jobs, ignoring emotional/social. Assuming you know the user without talking to them. No validation plan.

## Dimension Relationships

Dimensions are not independent — insights in one dimension affect others. The explorer tracks these connections and surfaces them.

**Key relationships:**
- **Product <-> Users:** Product features should map to user jobs. If a feature does not serve a job, question it.
- **Product <-> Tech:** Technical constraints shape what is buildable. Tech choices should serve product goals, not the reverse.
- **Market <-> Business:** Market size and dynamics constrain the business model. Pricing must match market willingness to pay.
- **Market <-> Competitors:** Competitor density and strength affect market entry strategy.
- **Users <-> Competitors:** What users hire today (competing solutions) defines your real competition.
- **Business <-> Tech:** Build-vs-buy decisions affect both cost structure and time to market.

**When exploring a dimension, the explorer should:**
- Reference relevant insights from previously explored dimensions.
- Flag contradictions ("You said the target is solo developers, but this pricing assumes enterprise budgets").
- Note when a dimension reveals something that changes an earlier conclusion.

## Suggested Exploration Order

For new ideas, this order tends to work well:

1. **Product** — Start with what and why. Get the core idea sharp.
2. **Users** — Understand who needs this and how they behave.
3. **Market** — Validate that the opportunity is real and reachable.
4. **Competitors** — Honest assessment of the landscape.
5. **Business** — How it works as a business.
6. **Tech** — How to build it (last because tech should serve the above, not drive it).

**This is a suggestion, not a rule.** The user can explore in any order. Some ideas start with a technical insight (tech first), some start with a market observation (market first). The explorer adapts.

## When to Revisit a Dimension

Signals from other dimensions that invalidate earlier work:

- **Revisit Product if:** Users exploration reveals the real pain is different from what was assumed. Competitor analysis shows the differentiator is not actually different.
- **Revisit Users if:** Market exploration reveals a better target segment. Product pivot changes who the user is.
- **Revisit Market if:** Business model requires a market segment that was not considered. Competitor analysis reveals the market is more crowded than assumed.
- **Revisit Business if:** Tech exploration reveals costs are much higher than assumed. Market pricing research contradicts revenue model.
- **Revisit Competitors if:** New information surfaces (researcher agent findings, user insights). A competitor is doing exactly what was planned.
- **Revisit Tech if:** Product scope changes significantly. Cost constraints from business model require different architecture.

**How the explorer handles this:** "Based on what we just found about [insight], your earlier assumption about [dimension] might need revisiting. Want to go back to that, or note it and continue?"
