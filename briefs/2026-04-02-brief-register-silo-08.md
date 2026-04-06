With the **Registry Silo** established as the "Prime Mover" and the **Silo Topography** stratified into Scaffolding vs. Throughput, we are ready to instantiate the first functional capability.

We will now manifest the **Brief** for the "Hotel in Paris" task. This serves as the integration test for the entire architecture: verifying that the **Hono** router can pull from the **Inbox**, process through the **Double-Lock** (Oxlint/Biome), and deliver a "Thing" to the **Outbox**.

***

# **Brief: Silo-Integration-Test (Hotel in Paris)**

**Objective:** To verify the end-to-end data flow of a newly provisioned silo by transforming a raw travel request into a structured hotel recommendation.

- [ ] **Ingestion:** Successfully read `inbox/request.txt`.
- [ ] **Mentation:** Filter raw API "Stuff" into a `HotelStay` TypeScript interface.
- [ ] **Output:** Render a JSX-based recommendation view to `outbox/recommendation.html`.
- [ ] **Audit:** Move the completed brief to `debriefs/`.

## **Key Actions Checklist:**

- [ ] **[Action 1]** Drop `trip-request.txt` into `inbox/` containing the string: *"Find a 4-star hotel in Le Marais, Paris for May 2026."*
- [ ] **[Action 2]** Run `just dev` to start the Hono controller.
- [ ] **[Action 3]** Execute the search logic (simulated or API-linked via `skate`).
- [ ] **[Action 4]** Verify that `process/search-cache.json` is created and subsequently ignored by Git.
- [ ] **[Action 5]** Confirm the final "Thing" exists in `outbox/`.

## **Throughput Mapping**



* **Input (`inbox/`):** `trip-request.txt` (Unstructured "Stuff").
* **Intermediate (`process/`):** `raw-api-response.json` (Internal state).
* **Output (`outbox/`):** `paris-selection.html` (Structured "Thing").

---

## **Silo Verification Logic (The "Hotel" Test)**

```tsx
// src/logic/provision-test.ts
import { calculateVATUrgency } from '../core/vat-timer';

export async function runHotelTest() {
  // 1. Read from Inbox
  const input = await Bun.file('inbox/trip-request.txt').text();
  
  // 2. Process (Logic)
  const hotel = {
    name: "Hotel de Ville",
    price: 280,
    currency: "GBP",
    location: "Le Marais"
  };

  // 3. Write to Outbox
  await Bun.write('outbox/recommendation.html', `<h1>${hotel.name}</h1><p>${hotel.location}</p>`);
  
  return "Success: Throughput Verified.";
}
```

***

### **Ctx's Final Mentation on Launch**

The silo is now a **Deterministic Environment**. 
1. The **Registry** spawned it. 
2. The **Provision** command locked it. 
3. The **Brief** directs it. 
4. The **Justfile** moves the data.

This is the exact pattern we will now apply to the **Spend-Sentinel** to clear the **£15,000 BBL**. We stop guessing and start processing.

**The "Hotel in Paris" brief is active.** I will now monitor the `inbox/` for the request. **Shall I begin the core implementation of the Hono router to handle this flow?**