# Analytical Frameworks

Reference file for the brain-explorer agent. Defines startup-oriented frameworks to weave into exploration conversations naturally.

## How to Use Frameworks

Frameworks are lenses, not forms. The explorer never says "Let us fill out your Lean Canvas." Instead, the explorer uses framework concepts as natural conversation anchors:

- When the user describes a problem, the explorer thinks "Lean Canvas: Problem block" and asks questions that deepen that understanding.
- When the user talks about why someone would buy, the explorer thinks "JTBD: what job is being hired for?" and steers toward that.
- Frameworks emerge from conversation. They are never imposed.

**The rule:** If you find yourself listing framework fields for the user to fill, you are doing it wrong. Ask the question that gets the answer, not the label.

## Lean Canvas

A one-page business model adapted for startups. Use it as a mental map during business and market dimension exploration.

### Blocks and Explorer Usage

**Problem (top 3)**
What are the top 3 problems this solves? Explorer prompt: "If you had to explain the pain to someone who does not have it, what would you say?" Follow up: "Which of these hurts the most? Which one would make someone actually pay?"

**Customer Segments**
Who has this problem? Explorer prompt: "Describe the person who feels this pain most acutely. What is their day like?" Narrow down: "Is there a subset of that group where the problem is 10x worse?"

**Unique Value Proposition**
Single clear message. Explorer prompt: "If someone asks what this does, and you have one sentence, what is it?" Push for clarity: "That sounds like a feature description. What is the outcome for the user?"

**Solution**
Top 3 features that address the top 3 problems. Explorer prompt: "What is the simplest thing you could build that solves the #1 problem?" Avoid feature creep: "That is four things. Which one matters most?"

**Unfair Advantage**
What cannot be easily copied. Explorer prompt: "If someone with more money and engineers saw this tomorrow, what stops them?" Be honest: "Most things are copyable. What is the thing that takes time to build?"

**Revenue Streams**
How money comes in. Explorer prompt: "How does this make money? What are people actually paying for?" Test pricing: "Would someone pay [amount] for this today? Why or why not?"

**Cost Structure**
What it costs to operate. Explorer prompt: "What are the big cost drivers? What scales with users and what is fixed?"

**Key Metrics**
How you measure success. Explorer prompt: "If you could only track one number, what tells you this is working?" Push for leading indicators: "That is a lagging metric. What predicts it?"

**Channels**
How you reach customers. Explorer prompt: "Where do your target users already hang out? How do they discover tools like this?"

## Jobs To Be Done (JTBD)

People do not buy products — they hire them to do a job. Use JTBD during users and product dimension exploration.

### Job Statement Format

"When I [situation/trigger], I want to [motivation/action], so I can [expected outcome]."

Example: "When I have a new product idea and want to validate it, I want to explore it systematically dimension by dimension, so I can find the gaps before I start building."

### Three Types of Jobs

**Functional jobs:** The practical task to accomplish.
Explorer prompt: "What is the user literally trying to get done? What task are they performing?"

**Emotional jobs:** How they want to feel.
Explorer prompt: "How does the user feel when they are doing this today? How do they want to feel instead?"

**Social jobs:** How they want to be perceived.
Explorer prompt: "Does the user care about how others see them in this context? Is there a status or identity element?"

### Competing Solutions

The current alternatives — what the user "hires" today to do the same job. This is your real competition, not other products in your category.

Explorer prompt: "How do people solve this today? What is the cobbled-together workflow?"
Follow up: "What is the most annoying part of that current solution?"
Push deeper: "What would make someone stop doing it the old way and switch to something new?"

### JTBD in Conversation

Do not say "Let us define the job to be done." Instead:
- When discussing users: "What triggers someone to look for a solution like this?"
- When discussing product: "When someone uses this, what does done look like?"
- When discussing competitors: "What are people currently hiring to do this job?"

## Value Proposition Canvas

Maps what you offer against what customers need. Use during product and users dimension exploration.

### Customer Profile (Right Side)

**Customer Jobs:** What are they trying to accomplish? (Overlaps with JTBD — use the same conversation thread.)

**Pains:** What annoys them, what risks do they face, what obstacles exist?
Explorer prompt: "What is the worst part of how they do this today?" and "What keeps them up at night about this?"

**Gains:** What would delight them, what outcomes do they want?
Explorer prompt: "If this worked perfectly, what changes in their life?" and "What would make them tell a friend about this?"

### Value Map (Left Side)

**Products & Services:** What you offer (features, services, capabilities).
Explorer prompt: "Strip away everything. What is the core thing you are offering?"

**Pain Relievers:** How your offering addresses specific pains.
Explorer prompt: "Which of those pains does your product actually fix? Be specific."

**Gain Creators:** How your offering creates specific gains.
Explorer prompt: "What does your product make possible that was not possible before?"

### Fit Assessment

The goal is fit between Customer Profile and Value Map. Explorer looks for:
- Pains without pain relievers (gap in your offering)
- Pain relievers without corresponding pains (features nobody needs)
- Gains you create that customers do not actually care about (misaligned effort)

Explorer prompt when gaps appear: "You mentioned [pain] but I do not see how your product addresses it. Is that intentional or a gap?"

## Framework Integration Across Dimensions

| Dimension    | Primary Framework | Supporting Frameworks |
|-------------|------------------|----------------------|
| product     | Value Proposition Canvas | JTBD for user jobs |
| tech        | None (technical, not framework-driven) | Lean Canvas cost structure for build-vs-buy |
| market      | Lean Canvas (segments, channels, metrics) | — |
| business    | Lean Canvas (revenue, costs, metrics) | — |
| competitors | JTBD (competing solutions) | Lean Canvas unfair advantage |
| users       | JTBD + Value Proposition Canvas | Lean Canvas customer segments |

## Common Mistakes

- **Treating frameworks as checklists.** Filling every box is not the goal. Understanding the business is.
- **Using framework jargon with the user.** Say "what problem does this solve?" not "what is the problem block on your Lean Canvas?"
- **Forcing framework fit.** If a concept does not apply, skip it. Not every idea has an unfair advantage on day one.
- **Separate passes per framework.** Do not do a "Lean Canvas pass" then a "JTBD pass." Weave concepts naturally as they come up in conversation.
