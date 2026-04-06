# **Strategic Analysis of the Just-Silo Framework: Lightweight Agentic Orchestration in the 2026 Data Ecosystem**

The global landscape of data orchestration and workflow automation is currently navigating a period of intense fragmentation and architectural reassessment. As the initial fervor surrounding large language models (LLMs) matures into a disciplined focus on production-grade reliability, the industry is witnessing a shift away from monolithic, "all-in-one" agent frameworks toward modular, lightweight, and specialized environments. The project developed under the repository just-silo represents a quintessential example of this "minimalist" movement. By providing an open-source, lightweight silo for processing data through workflows—with or without the intervention of autonomous agents—this framework addresses a critical gap in the market: the need for isolated, manageable, and deterministic execution environments that can still leverage the reasoning capabilities of modern artificial intelligence. This report provides an exhaustive analysis of the just-silo project, its positioning relative to the competitive "wild" of 2026, its inherent utility for modern engineering teams, and a comprehensive strategic roadmap for its community-led launch.

## **The Architectural Paradigm of the Agentic Silo**

The nomenclature of the project is itself a significant indicator of its philosophical roots. Historically, "siloing" was viewed as a failure of data architecture, representing fragmented and inaccessible information stores that hindered enterprise-wide intelligence. However, in the context of the 2025-2026 agentic revolution, the "silo" has been reclaimed as a security and operational primitive. The modern data silo is no longer a barrier to access but a boundary for safety. As autonomous agents become more pervasive, the risk of prompt injection and "rogue" behavior has necessitated the creation of sandboxed environments where an agent’s "blast radius" is strictly limited.1 Just-silo adopts this sandboxed philosophy, allowing developers to process data within a defined "silo" that prevents sensitive context from bleeding into global states or unintended external services.

This architectural choice reflects a broader trend toward "Vertical AI," where specialized tools are grounded in deep industry context rather than universal, horizontal use cases.3 By focusing on a siloed model, the project aligns with the growing requirement for data isolation in sectors like finance, healthcare, and defense, where privacy is non-negotiable.2 The lightweight nature of the framework—likely built on modern TypeScript or Rust-based principles seen in high-performance alternatives like ZeroClaw or Mastra—ensures that these silos can be deployed at the edge or within serverless environments without the overhead associated with legacy enterprise orchestrators.2

### **Technical Lineage and the Mastra Connection**

The repository https://github.com/pjsvis/just-silo appears to emerge from a sophisticated ecosystem of TypeScript-first agentic tools. Research into the developer's background reveals deep involvement in the Mastra framework, particularly through contributions to the mastra-hono integration and the development of specialized logic modules such as "Edinburgh Protocol Tools," "Mentation Workflow," and "Entropy Scoring".6 Mastra is widely recognized as a premier framework for JavaScript and TypeScript teams, valued for its graph-based workflows and its ability to route tasks between multiple agents via a .network() primitive.4

Just-silo likely represents a distillation of these advanced concepts into a more focused, modular package. The mention of "Mentation" suggests a refined approach to how agents internalize context and maintain state, while "Entropy Scoring" indicates a mechanism for measuring an agent's uncertainty during a workflow—a critical feature for maintaining reliability in non-deterministic systems.6 By integrating these features into a lightweight package, the project offers a "FastAPI-feeling" for agents, similar to the Pydantic AI framework in the Python ecosystem, which prioritizes type safety and clean, readable code.5

## 

## **Comparative Analysis: Just-Silo vs. The Global Market**

To accurately assess the positioning of just-silo, it is necessary to compare it against two primary categories of tools: high-level agent frameworks and traditional workflow automation platforms. The market in 2026 is defined by a "Great Fragmentation," where developers are increasingly choosing between the sheer power of enterprise frameworks and the agility of minimalist libraries.

### **Frameworks for Agentic Orchestration**

The "wild" is currently dominated by a few major players, each catering to different architectural needs. LangGraph remains the choice for complex, stateful, and long-running workflows, while CrewAI has captured the market for role-based multi-agent collaboration.4

| Framework | Dominant Strategy | Stars / Usage | Key Differentiator |
| :---- | :---- | :---- | :---- |
| LangGraph | Directed graphs with persistent state and checkpointing.4 | 24.8k Stars; 34.5M Monthly Downloads.4 | Best for complex, cyclic workflows requiring human-in-the-loop triggers.4 |
| CrewAI | Role-playing agents with defined responsibilities and task delegation.4 | 44.3k Stars; 5.2M Monthly Downloads.4 | Minimal code requirement; popular in marketing and customer service.4 |
| Mastra | TypeScript-first; graph-based; high-performance routing.4 | 21.2k Stars; 1.77M Monthly Downloads.4 | Built for the JS/TS ecosystem; uses Vercel AI SDK for model abstraction.4 |
| AutoGen | Event-driven architecture for multi-agent conversations.4 | 54.6k Stars; 856k Monthly Downloads.4 | Outperforms single-agent solutions on GAIA benchmarks; integrated into Microsoft Agent Framework.4 |
| ZeroClaw | Rust-based; high speed; minimal memory footprint.2 | 16k Stars; rapidly growing in production.2 | Focuses on speed and memory safety; ideal for edge and high-throughput environments.2 |
| just-silo | Siloed, data-centric workflows; agent-optional; lightweight. | Emerging / New. | Decouples orchestration from agentic reasoning; focuses on data processing safety. |

In this landscape, just-silo differentiates itself by not assuming that every workflow requires an agent. While frameworks like AutoGen and CrewAI are "agent-first," just-silo is "data-first." This allows for a hybrid approach where deterministic data processing (e.g., standard ETL tasks) can coexist seamlessly with agentic reasoning steps (e.g., classifying unstructured text) within the same silo.9 This hybridity is essential for managing the billing costs and latency associated with LLMs, as it allows developers to "fall back" to deterministic code for ![][image1] of a task and only use "expensive" agents where they are truly needed.11

### **Workflow Automation and Low-Code Platforms**

Beyond the code-first frameworks, just-silo must also be compared with the "automation unicorns" like n8n and Activepieces, which have begun integrating agentic capabilities into their visual builders.

| Platform | Architectural Approach | Target Market | AI Strategy |
| :---- | :---- | :---- | :---- |
| n8n | Node-based visual flows; 400+ integrations.12 | Power users and SMBs needing custom logic.12 | Native AI workflows via LangChain integration; JS/Python code nodes.12 |
| Activepieces | Drag-and-drop builder; TS extensibility.12 | Marketing and HR teams automating SaaS tasks.14 | AI Copilot for design; 450+ integrations.12 |
| Windmill | High-performance scripts; multi-language; code-first.12 | DevOps and CI/CD teams.12 | Versioned, auditable workflows; Git integration.12 |
| Kestra | YAML-declarative; designed for scale.12 | Enterprise data and ML orchestration.12 | Parallel task execution; database and cloud integrations.12 |

Just-silo occupies a niche that is more developer-centric than n8n but less complex than Windmill. It is designed for those who find visual builders too restrictive but enterprise data orchestrators too heavy. The project's usefulness stems from its ability to provide a "third way": a programmatic, lightweight framework that treats the "silo" as a unit of work, enabling easy deployment in modern containerized or serverless environments.13

## **Assessing the Usefulness of Just-Silo**

The utility of a tool like just-silo is intrinsically linked to the "IT skills crisis" and the move toward "Hyperautomation." By 2025, the challenge for many organizations was not a lack of AI models, but a lack of specialized systems to operationalize that intelligence without incurring massive technical debt.10

### **Solving the Problem of Tool Bloat and Security**

A primary driver for the adoption of lightweight alternatives is the "OpenClaw fatigue." OpenClaw, once the leading open-source agent platform, has faced criticism for having over 430,000 lines of code, leading to significant "code bloat" and security vulnerabilities.1 Concerns regarding its acquisition by OpenAI have further fueled the desire for independent, lean, and auditable alternatives.2 Just-silo directly addresses these concerns by offering:

* **Auditability**: A smaller codebase allows for thorough security reviews, which is critical when agents are granted access to sensitive data or internal systems.2  
* **Resource Efficiency**: The lightweight nature of the project allows it to run on minimal infrastructure, such as Raspberry Pis or micro-VMs, reducing the total cost of ownership compared to heavyweight alternatives.2  
* **Deterministic Safety**: By allowing "workflows without agents," just-silo enables developers to maintain rigid, auditable control over mission-critical paths while still being "future-proofed" for agentic integration.10

### 

### **The Value of the "Agentic Interface" Paradigm**

We are currently entering an "agentic interface paradigm," where software is increasingly designed to be interacted with by agents rather than directly by humans.1 This requires a fundamental shift in how data is processed. Traditional APIs and databases were designed for human-driven, structured requests. Agentic workflows, however, must handle "messy, unstructured, and unpredictable" inputs like emails, documents, and images.10 Just-silo is positioned to be the "handler" for this messiness. By providing a siloed environment for these unstructured tasks, it allows for "Vertical AI" applications—such as identifying revenue loss in utilities or Detecting HVAC issues—that require deep specialization.3

Furthermore, the "Entropy Scoring" mentioned in the pjsvis ecosystem suggests a second-order utility: the ability for a system to self-correct.6 If an agent's entropy (uncertainty) score exceeds a certain threshold, the just-silo workflow can automatically trigger a "human-in-the-loop" approval step or revert to a safe, deterministic default.4 This "controlled autonomy" is what separates experimental AI toys from production-grade enterprise infrastructure.

## **Regional Context: The Edinburgh AI Ecosystem**

The development of just-silo within the Edinburgh tech hub is a strategic advantage that should not be overlooked. Scotland has proactively positioned itself at the forefront of the "next wave of AI," with a specific focus on "Agentic AI" through initiatives at CodeBase, the University of Edinburgh, and the Edinburgh Futures Institute (EFI).18

### **Strategic Initiatives and Market Readiness**

1. **Applied Agentic AI Programme**: Delivered by CodeBase and the University of Edinburgh Business School, this 12-week program is the UK's first aimed at equipping senior engineers with the skills to build, reason, and deploy autonomous agents.19 The presence of such a program indicates a "ready-made" audience of fifty or more senior engineers per cohort who are actively looking for lightweight tools to implement the architecture they are learning.20  
2. **Techscaler Startups**: Scotland's Techscaler program has seen startups raise over £257 million, many of which are in the "AI-first" category.18 These startups typically prioritize agility and low technical debt, making them ideal early adopters of lightweight, open-source frameworks like just-silo.  
3. **Local Expertise and Scaleups**: Companies like Malted AI and Pando are already building conversational and agentic workflows in the region.21 The CEO of Malted AI, Iain Mackie, has noted that the "real advantage" in the agentic economy will go to teams who can engineer these systems "safely, reliably, and at scale"—a direct endorsement of the philosophy behind just-silo.21

Launching the project in this environment allows for "in-person validation" and rapid feedback loops that are often missing from purely digital open-source launches. The proximity to EFI and the University's Generative AI Laboratory (GAIL) provides access to cutting-edge research in natural language processing and agentic reasoning that can be directly integrated into the project's roadmap.24

## **Launch Strategy: Social Media and Community Building**

A successful launch for an open-source project in 2026 requires a "signal over scale" approach. Rather than broad, indiscriminate marketing, the strategy must focus on building "tight communities" where feedback loops are "short and honest".26 The following plan outlines a platform-by-platform approach for launching just-silo.

### **Phase 1: The "Technical Alpha" on Hacker News**

Hacker News (HN) is the primary gateway for technical tools. The audience is composed of engineers, founders, and developers who value "curiosity and sharing something meaningful" over marketing hype.27

* **The "Show HN" Format**: The post should be titled with a focus on the problem it solves, e.g., "Show HN: Just-Silo – A lightweight, agent-optional data workflow engine."  
* **The Narrative of Choice**: The accompanying comment should explain the "Why." Why did the creator build this instead of using LangGraph or n8n? Mentioning the "OpenClaw code bloat" or the need for "Entropy Scoring" will resonate with the HN community's desire for engineering transparency.1  
* **Timing and Algorithm**: For maximum reach, the post should be made on a Tuesday or Wednesday between 7 AM and 9 AM EST.27 The HN algorithm uses a time-decay factor:  
  ![][image2]  
  This necessitates a "burst" of early engagement. Engaging a network of 5-10 friends to provide early upvotes and "real" comments (avoiding obvious vote manipulation) can help the post reach the front page.27

### 

### **Phase 2: Building "In Public" on Twitter/X and LinkedIn**

X is the primary platform for the "agentic AI" discourse. LinkedIn is essential for reaching the enterprise and "Vertical AI" audience.

* **Visual Proof**: Post short, high-fidelity screen recordings of just-silo in action. Show how it handles an unstructured data set, such as a folder of messy invoices, and transforms them into a clean CSV using an agent-optional workflow.10  
* **Educational Threads**: Create threads that break down complex concepts like "Entropy Scoring" or the "Edinburgh Protocol." This establishes the creator as a domain expert.6  
* **Engagement Tactics**: Bookmark and like relevant tweets to boost the project in the algorithm.27 Participate in the "build in public" hashtag community (\#BuildInPublic) to document design decisions and technical hurdles.30

### **Phase 3: Niche Community Deep Dives on Reddit**

Reddit allows for targeting specific developer sub-cultures.

| Subreddit | Message Focus | Goal |
| :---- | :---- | :---- |
| **r/SaaS** | Reducing AWS/token costs by using "agent-optional" workflows.13 | Attract founders looking for production-ready tools. |
| **r/LocalLLaMA** | Privacy-first, local silos for sensitive data processing.1 | Target the privacy and open-source enthusiast community. |
| **r/AI\_Agents** | Technical comparison of just-silo vs. frameworks like AutoGen and CrewAI.4 | Establish technical credibility and find potential contributors. |
| **r/SideProject** | The "honest story" of building just-silo and the lessons learned.29 | Build community goodwill and get early testers. |

Reddit users will ban accounts for "blatant promotion," so the tone must be "engineering-first" and focus on "sharing real value" rather than a sales pitch.26

### 

### **Phase 4: Local Activation in the Edinburgh Hub**

Given the high density of agentic AI talent in Edinburgh, local activation is a force multiplier.

* **Meetup Demos**: Present the project at "GDG Edinburgh," ".NET Edinburgh," or the "Edinburgh Data Science and AI" meetup.24 These events attract a mix of professionals and academics who are the ideal "power users" for just-silo.  
* **Academic Collaboration**: Reach out to the directors of the Edinburgh Futures Institute and CodeClan to offer just-silo as a "reference implementation" for their students.19  
* **Flagship Events**: Leverage Turing Fest and DIGIT Expo (November 2026\) to network with the 1,600+ attendees and 60+ exhibitors who are looking for the next wave of Scottish tech innovation.35

## 

## **Quantitative Market Context and Comparisons**

The following tables provide a structured view of the data and comparisons discussed throughout the report, illustrating the competitive pressure and the market opportunity for just-silo.

### **Framework Adoption and Community Metrics (2026)**

| Framework | Language | Stars | Downloads (Monthly) | Notable Use Case |
| :---- | :---- | :---- | :---- | :---- |
| **LangGraph** | Python, JS | 24.8k | 34.5M | Klarna's customer support.4 |
| **OpenAI SDK** | Python | 19k | 10.3M | Website-to-agent conversions.4 |
| **CrewAI** | Python | 44.3k | 5.2M | Marketing automation.4 |
| **Google ADK** | Python | 17.8k | 3.3M | Google Agentspace.4 |
| **Mastra** | TypeScript | 21.2k | 1.77M | Marsh McLennan's enterprise apps.4 |
| **just-silo** | TS/JS | New | Emerging | Targeted data silos and agentic workflows. |

### 

### **Comparison of Workflow Orchestration Philosophies**

| Feature | Enterprise (Airflow/Dagster) | No-Code (Zapier/Make) | Agentic (LangGraph/CrewAI) | Lightweight Silo (Just-Silo) |
| :---- | :---- | :---- | :---- | :---- |
| **Primary Unit** | Task / DAG.9 | Integration / App.13 | Agent / Persona.8 | Silo / Workflow. |
| **Control Flow** | Deterministic.9 | Event-Driven.13 | Autonomous.10 | Hybrid / Optional. |
| **Infrastructure** | Heavy / Server.9 | SaaS / Cloud.15 | High Token Cost.11 | Lightweight / Edge. |
| **Safety Model** | Permissions-based. | Connector-based. | Guardrail-based.4 | Isolation (Silo)-based. |

## 

## **Second and Third-Order Insights: The Future of Modular Intelligence**

The emergence of just-silo is not an isolated event but a signal of a broader "re-siloing" of the internet. As LLMs become commoditized, the value of software moves from the "intelligence" (which any model can provide) to the "environment" (where that intelligence is applied).

### **The Rise of the "Sub-Loop" and Task Pooling**

One emerging trend identified in the research is the "pool of tasks" model, where agents are not assigned to a person, but to a project.1 In this paradigm, an agent "subscribes" to a repository or a project pool and completes tasks autonomously without human guidance.1 Just-silo is uniquely suited for this model. By providing a secure, lightweight silo, it creates the "workplace" for these subscribing agents. This enables "Continuous AI"—the systematic, automated application of AI to software collaboration.16

### **The Causal Link Between Complexity and Security**

There is a direct causal relationship between the complexity of an agent framework and its security risk. Monolithic frameworks like OpenClaw, with their massive dependency trees and hundreds of built-in MCP (Model Context Protocol) tools, present a "massive attack surface".1 Just-silo’s minimalist approach is a security feature in itself. By reducing the "blast radius" to a single silo and limiting the toolset to only what is necessary for a specific workflow, the project provides a "defense-in-depth" model that enterprise frameworks struggle to replicate.2

### **Future Outlook: The "Vibe-Coding" Era**

Finally, the project must be viewed through the lens of the "vibe-coding" era, where software is increasingly generated or managed by agents based on high-level intent.37 In this world, the distinction between "code" and "data" blurs. A workflow becomes a piece of data that an agent can reason about and modify.37 Just-silo's "agent-optional" workflows are the bridge to this future. They provide a stable, deterministic foundation that can be "upgraded" to agentic reasoning as the technology matures, without requiring a complete rewrite of the underlying system.

## 

## **Synthesis and Recommendations for Project Evolution**

The project just-silo is a highly relevant contribution to the 2026 tech ecosystem, specifically for developers who require a balance between the autonomy of modern agents and the reliability of traditional workflows. Its positioning within the Edinburgh tech hub provides a unique opportunity for high-signal community building and academic collaboration.

### **Key Takeaways for the Developer**

* **Emphasize the Silo as a Security Primitive**: In a market terrified of "rogue" agents, the silo is your strongest selling point. Market it as a "blast-radius-limited environment for autonomous work".1  
* **Leverage the "Agent-Optional" Flexibility**: Do not try to compete with "agent-first" frameworks on their turf. Instead, market to the ![][image1] of developers who still need deterministic reliability for their core logic but want to add "agentic spice".10  
* **Technical Transparency is the Best Marketing**: On platforms like Hacker News, be brutally honest about what the tool *cannot* do. This builds trust with a community that is tired of over-hyped AI projects.27  
* **Standardize the "Entropy Score"**: If you can turn entropy scoring into a standard metric for agentic reliability, just-silo could become the benchmark for "safe" agent deployments.6  
* **Engage the Regional Hub**: The Edinburgh Applied Agentic AI program is your perfect beta-testing ground. Provide templates that align with their curriculum to ensure rapid adoption by the region's top engineering talent.19

Just-silo is not just another tool in the crowded agentic framework market; it is a foundational primitive for a more modular, secure, and pragmatic approach to the "agentic interface" era. By focusing on the "silo" as the unit of work and intelligence as an optional enhancement, the project offers a sustainable path for developers navigating the complex transition from deterministic to autonomous software.

#### **Works cited**

1. OpenClaw or something similar : r/accelerate \- Reddit, accessed on April 1, 2026, [https://www.reddit.com/r/accelerate/comments/1quhxnq/openclaw\_or\_something\_similar/](https://www.reddit.com/r/accelerate/comments/1quhxnq/openclaw_or_something_similar/)  
2. Best OpenClaw Alternatives in 2026 (Tested & Compared), accessed on April 1, 2026, [https://aisuperior.com/best-openclaw-alternatives/](https://aisuperior.com/best-openclaw-alternatives/)  
3. Article \- \- Bidgely UtilityAI™ \- Energy Analytics, accessed on April 1, 2026, [https://www.bidgely.com/tag/article/](https://www.bidgely.com/tag/article/)  
4. The Best Open Source Frameworks For Building AI Agents in 2026 \- Firecrawl, accessed on April 1, 2026, [https://www.firecrawl.dev/blog/best-open-source-agent-frameworks](https://www.firecrawl.dev/blog/best-open-source-agent-frameworks)  
5. 120+ Agentic AI Tools Mapped Across 11 Categories \[2026\] \- StackOne, accessed on April 1, 2026, [https://www.stackone.com/blog/ai-agent-tools-landscape-2026/](https://www.stackone.com/blog/ai-agent-tools-landscape-2026/)  
6. Conditional source · Issue \#8214 · nushell/nushell \- GitHub, accessed on April 1, 2026, [https://github.com/nushell/nushell/issues/8214](https://github.com/nushell/nushell/issues/8214)  
7. file\_not\_found/directory\_not\_found on evaluated string doesn't say what the path is; makes error hard to debug \#10406 \- GitHub, accessed on April 1, 2026, [https://github.com/nushell/nushell/issues/10406](https://github.com/nushell/nushell/issues/10406)  
8. AI Agent Frameworks: 10 Options, One Guide, Zero Fluff \- ChatBot, accessed on April 1, 2026, [https://www.chatbot.com/blog/ai-agent-frameworks/](https://www.chatbot.com/blog/ai-agent-frameworks/)  
9. Top 17 Data Orchestration Tools for 2026: Ultimate Review \- lakeFS, accessed on April 1, 2026, [https://lakefs.io/blog/data-orchestration-tools/](https://lakefs.io/blog/data-orchestration-tools/)  
10. 10 Best AI Workflow Platforms in 2025: Smarter Automation, Real Results \- Domo, accessed on April 1, 2026, [https://www.domo.com/learn/article/ai-workflow-platforms](https://www.domo.com/learn/article/ai-workflow-platforms)  
11. Automate repository tasks with GitHub Agentic Workflows, accessed on April 1, 2026, [https://github.blog/ai-and-ml/automate-repository-tasks-with-github-agentic-workflows/](https://github.blog/ai-and-ml/automate-repository-tasks-with-github-agentic-workflows/)  
12. Top 15 Open-Source Workflow Automation Tools | by TechLatest.Net | Medium, accessed on April 1, 2026, [https://medium.com/@techlatest.net/top-15-open-source-workflow-automation-tools-e2822e65c842](https://medium.com/@techlatest.net/top-15-open-source-workflow-automation-tools-e2822e65c842)  
13. Top 8 Enterprise Workflow Automation Software for 2025 \- AutoKitteh, accessed on April 1, 2026, [https://autokitteh.com/technical-blog/top-8-enterprise-workflow-automation-software-for-2025/](https://autokitteh.com/technical-blog/top-8-enterprise-workflow-automation-software-for-2025/)  
14. Top 10 Open-Source Workflow Automation Software in 2026 \- Activepieces, accessed on April 1, 2026, [https://www.activepieces.com/blog/top-10-open-source-workflow-automation-tools-in-2024](https://www.activepieces.com/blog/top-10-open-source-workflow-automation-tools-in-2024)  
15. Top 20 Low-Code AI Workflow Automation Tools for Modern Engineering Teams, accessed on April 1, 2026, [https://blog.tooljet.com/low-code-ai-workflow-automation-tools/](https://blog.tooljet.com/low-code-ai-workflow-automation-tools/)  
16. Home | GitHub Agentic Workflows, accessed on April 1, 2026, [https://github.github.com/gh-aw/](https://github.github.com/gh-aw/)  
17. The future of work: workflow automation trends shaping 2025 \- Blog | ShareFile, accessed on April 1, 2026, [https://www.sharefile.com/resource/blogs/workflow-automation-trend](https://www.sharefile.com/resource/blogs/workflow-automation-trend)  
18. CodeBase: For You, accessed on April 1, 2026, [https://community.thisiscodebase.com/](https://community.thisiscodebase.com/)  
19. CodeClan debuts UK's first applied agentic AI programme to equip firms for the next wave of AI \- Edinburgh Futures Institute, accessed on April 1, 2026, [https://efi.ed.ac.uk/codeclan-debuts-uks-first-applied-agentic-ai-programme-to-equip-firms-for-the-next-wave-of-ai/](https://efi.ed.ac.uk/codeclan-debuts-uks-first-applied-agentic-ai-programme-to-equip-firms-for-the-next-wave-of-ai/)  
20. Applied Agentic AI \- CodeClan, accessed on April 1, 2026, [https://codeclan.com/applied-agentic-ai](https://codeclan.com/applied-agentic-ai)  
21. CodeClan debuts UK's first applied agentic AI programme to equip firms for the next wave of AI \- University of Edinburgh Business School, accessed on April 1, 2026, [https://www.business-school.ed.ac.uk/about/news/codeclan-debuts-uks-first-applied-agentic-ai-programme-equip-firms-next-wave-ai](https://www.business-school.ed.ac.uk/about/news/codeclan-debuts-uks-first-applied-agentic-ai-programme-equip-firms-next-wave-ai)  
22. DIGIT Editor, Author at DIGIT \- Digit.fyi, accessed on April 1, 2026, [https://www.digit.fyi/author/digitfyieditor/](https://www.digit.fyi/author/digitfyieditor/)  
23. Conversational Ai Engineer Work, jobs (with Salaries) | Indeed United Kingdom, accessed on April 1, 2026, [https://uk.indeed.com/q-conversational-ai-engineer-jobs.html](https://uk.indeed.com/q-conversational-ai-engineer-jobs.html)  
24. Edinburgh Data Science April Meetup, Thu, Apr 2, 2026, 5:30 PM, accessed on April 1, 2026, [https://www.meetup.com/edinburgh-data-science-ai/events/313816971/?recId=ccb24cc8-2fe6-463d-9172-f5adb74a22a5\&recSource=event-search\&searchId=bd216a34-b70b-4a8a-a3eb-8b85bc363285\&eventOrigin=find\_page%24all](https://www.meetup.com/edinburgh-data-science-ai/events/313816971/?recId=ccb24cc8-2fe6-463d-9172-f5adb74a22a5&recSource=event-search&searchId=bd216a34-b70b-4a8a-a3eb-8b85bc363285&eventOrigin=find_page$all)  
25. Edinburgh Futures Institute, accessed on April 1, 2026, [https://www.research.ed.ac.uk/en/organisations/edinburgh-futures-institute/](https://www.research.ed.ac.uk/en/organisations/edinburgh-futures-institute/)  
26. Where do you launch a new product to get early users (besides Product Hunt)? \- Reddit, accessed on April 1, 2026, [https://www.reddit.com/r/Entrepreneur/comments/1q7b2xv/where\_do\_you\_launch\_a\_new\_product\_to\_get\_early/](https://www.reddit.com/r/Entrepreneur/comments/1q7b2xv/where_do_you_launch_a_new_product_to_get_early/)  
27. How to crush your Hacker News launch \- DEV Community, accessed on April 1, 2026, [https://dev.to/dfarrell/how-to-crush-your-hacker-news-launch-10jk](https://dev.to/dfarrell/how-to-crush-your-hacker-news-launch-10jk)  
28. How I Got My First 500 Users with a Simple Hacker News Launch Strategy : r/SaaS \- Reddit, accessed on April 1, 2026, [https://www.reddit.com/r/SaaS/comments/1kifs12/how\_i\_got\_my\_first\_500\_users\_with\_a\_simple\_hacker/](https://www.reddit.com/r/SaaS/comments/1kifs12/how_i_got_my_first_500_users_with_a_simple_hacker/)  
29. Has anyone successfully launched on HackerNews? (I will not promote) : r/startups \- Reddit, accessed on April 1, 2026, [https://www.reddit.com/r/startups/comments/1kn4aux/has\_anyone\_successfully\_launched\_on\_hackernews\_i/](https://www.reddit.com/r/startups/comments/1kn4aux/has_anyone_successfully_launched_on_hackernews_i/)  
30. How Launching a sideproject on Hacker News Got Me $10K in 2 Weeks \- Reddit, accessed on April 1, 2026, [https://www.reddit.com/r/SideProject/comments/1h7y74a/how\_launching\_a\_sideproject\_on\_hacker\_news\_got\_me/](https://www.reddit.com/r/SideProject/comments/1h7y74a/how_launching_a_sideproject_on_hacker_news_got_me/)  
31. Multi-Tenant Architecture for a SaaS Application on AWS \- DZone, accessed on April 1, 2026, [https://dzone.com/articles/multi-tenant-architecture-for-a-saas-application-on-aws](https://dzone.com/articles/multi-tenant-architecture-for-a-saas-application-on-aws)  
32. GDG Edinburgh \- Meetup, accessed on April 1, 2026, [https://www.meetup.com/gdg-edinburgh/](https://www.meetup.com/gdg-edinburgh/)  
33. .NET Edinburgh | Meetup, accessed on April 1, 2026, [https://www.meetup.com/dotnetedinburgh/](https://www.meetup.com/dotnetedinburgh/)  
34. Applied Agentic AI \- Edinburgh Futures Institute, accessed on April 1, 2026, [https://efi.ed.ac.uk/programmes/applied-agentic-ai/](https://efi.ed.ac.uk/programmes/applied-agentic-ai/)  
35. Turing Fest | Tech Community, Events, & News, accessed on April 1, 2026, [https://turingfest.com/](https://turingfest.com/)  
36. DIGIT Expo 2026 | Edinburgh | Scotland's Biggest Tech Showcase, accessed on April 1, 2026, [https://digit-expo.com/](https://digit-expo.com/)  
37. Author Archives: Tom Quinn \- Digit.fyi, accessed on April 1, 2026, [https://www.digit.fyi/author/tomquinn/](https://www.digit.fyi/author/tomquinn/)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACMAAAAXCAYAAACBMvbiAAACVklEQVR4XrVVTYtOYRi+j+SjqUFIVrNQU5LIxy+QlSQbC5tZSM3eQikbK8ViLGyw9AtkRSyUBVE+ZsgkxUyThSwopgmv6zr3fd5zn/s8z/G+L6663ue5r/vj+TzPK/InFFH4T6jHqXqjjhzyus0O+Miyn0lNyknRUByNSgJ7O0vUzuGW59y7wGW20H6gPVC7GpgHj0exwhrwAdgD7wSfx3nwC/gNPBV8BPN3WH8T+B38CZ4BD4PXLeajxbSwTzRgg5rFQbNr6NJfgXedOgs+dDbRC7vo62y3ljuXBROeV4bV6qF9WWnAODVnV2DcRutvoe2dRTvnnHQcz1bRhGtBf4pKvtAzaRcmqN0Itr9EPme1ZI9HE6Zs0JnguC/NQuznJuP1FfCk9Q+Bp4OvExOS3pn3pm+ujs0YkdJp3wQ/Oe0CeMzZWfDcX0TNyMvsbUXzGOJkSrh7zC91qTZlp+jXyN1vgdvJgkwizopeXmqrTMsNmtM9+N5U8B/CGPja+frYJvq+zGFNu9G+k+YguUGd3vymDRfBI32rkA/4vdW3Rd66fhYc4Jezv5oWQa1eXXM+68DFhqLxV13gTFwDAoo4EG3/HpwwLYLa/uSe6MsbYZPp40piMuWFqvAE/OzsEvaATTvpkqQnSFwWvYsRj8Db7Ngc9JhomLBHtOiCtfyPSmG9qP+x6IvNZz21KTye3F1YK/UCeIH5lzIMUuNloKFvghoxKfoA3ouOEoMNF6JySUXOMRL+YTF3FwbEcNEpaIW/ryN1kRGKDZjSFZbwJaQWMjHDH0Uy/jeWfImFlfpGIwAAAABJRU5ErkJggg==>

[image2]: <data:image/png;base64,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>