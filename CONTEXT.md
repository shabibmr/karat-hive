# Karat Hive Marketplace

A request-driven marketplace that matches retail gold buyers and sellers with verified jewellers in the UAE. The platform brokers competing Offers and introductions; it does not settle payment, delivery, or authenticity of goods.

## Actors

**Customer**:
A retail individual who creates Requests to buy or sell gold or jewellery. Not business-KYC’d by the platform; must bind a one-time external identity before publishing any Request.
_Avoid_: buyer, client, user (when meaning this role), account

**Vendor**:
A gold business or independent jeweller that, once verified and active with the right entitlements, receives matched Requests and submits Offers.
_Avoid_: jeweller (as primary term — synonym only), seller, merchant, shop, lead responder

**Platform Admin**:
Karat Hive staff who verify Vendors, moderate content, and operate the marketplace. Never self-registers.
_Avoid_: operator, moderator (unless referring only to review queue work), superuser

## Core loop

**Request**:
A Customer’s stated intent to buy or sell, of exactly one Request Type, live for a fixed window after publication unless accepted, cancelled, or removed earlier. The originating entity of the marketplace loop.
_Avoid_: post, listing, order, ticket, inquiry, RFQ (as primary term)

**Request Type**:
One of four kinds of Request: Find An Ornament, Sell Old Gold, Buy/Sell Gold Coin(s), Buy/Sell Gold Bullion. Immutable after publication; also the unit of Vendor subscription entitlement.
_Avoid_: category (Category is a separate matching taxonomy), product type

**Direction**:
Whether the Customer wants to buy or sell on a Request. Fixed by type for Find An Ornament (buy) and Sell Old Gold (sell); chosen by the Customer for coins and bullion.
_Avoid_: side, intent (alone)

**Offer**:
A Vendor’s priced, time-limited response to a single Request. At most one non-terminal Offer per Vendor per Request; at most one Offer per Request may be accepted.
_Avoid_: bid, quote (as primary), proposal, price, deal

**Acceptance**:
The Customer’s irreversible selection of exactly one Offer on a Request (the UI may label this “Mark as Interested”). Triggers Identity Reveal and Connection creation; rejects all other pending Offers on that Request.
_Avoid_: purchase, order confirmation, deal close, transaction complete

**Connection**:
The relationship created when an Offer is accepted. The sole authorisation basis for mutual identity access between that Customer and that Vendor for that introduction. Survives closure as a read-only record.
_Avoid_: deal, transaction, chat, match (match means Request–Vendor eligibility), conversation

**Talk**:
The action, available only on an active Connection, that opens off-platform contact with the counterparty. The platform records that contact was initiated, never conversation content.
_Avoid_: message, chat, call (call is a separate optional channel on revealed numbers)

**Introduction**:
What the platform successfully produces when a Connection is created: the parties can identify and contact each other. Not a completed sale.
_Avoid_: transaction, deal completion, conversion (when meaning a closed sale)

## Matching and eligibility

**Match Set**:
The set of Vendors eligible to see a given published Request, determined by verification, marketplace access, Category, Region, and active Type Subscription.
_Avoid_: audience, fan list, subscribers

**Fan-out**:
Distribution of a newly published Request to its Match Set, with notification to those Vendors.
_Avoid_: broadcast, push (alone), publish (publish means a Request going live)

**Category**:
Admin-maintained classification of goods or specialisation. One of the two matching dimensions; Vendors declare which Categories they serve.
_Avoid_: Request Type, tag, genre

**Region**:
Admin-maintained geographic area (for example emirate → area). The second matching dimension; Vendors declare which Regions they serve.
_Avoid_: location, zone, city (unless as a Region leaf name)

**Type Subscription**:
A paid Vendor entitlement to be matched to and offer on Requests of one specific Request Type. Independent per type; required in addition to Verification and marketplace access.
_Avoid_: plan, tier (alone), licence, package, membership (alone)

**Verification**:
Manual Platform Admin approval of a Vendor’s business credentials. Necessary but not sufficient for marketplace access; the Vendor must also have marketplace access and hold the relevant Type Subscription.
_Avoid_: KYC (as the product term — documents support verification), auto-approval, onboarding (broader)

**Marketplace Access**:
The Vendor state in which they may see matched Requests and submit Offers (subject to Type Subscription). Distinct from Verification: credentials may be approved while access is not yet granted, or access may be suspended after verification.
_Avoid_: active (as a vague adjective), enabled, live account (alone)

**Awaiting Approval**:
The constrained Vendor experience before marketplace access: status and document work only; no Request feed, Offers, or marketplace data.
_Avoid_: pending login, soft ban, limited mode (alone)

## Identity and trust

**Identity Masking**:
Mutual concealment of Customer and Vendor real-world identity until Acceptance. Enforced as a platform rule, not merely a UI hide.
_Avoid_: anonymity (parties are known to the platform), privacy mode, incognito

**Identity Reveal**:
Simultaneous release of each party’s contact identity to the other, scoped only to the Connection created by Acceptance.
_Avoid_: unmask, dox, share contacts (pre-acceptance is a violation)

**Review**:
A star rating and optional comment one party to a Connection leaves about the other. Submitted only against a Connection; at most one per party per Connection; held for Platform Admin approval before use in public aggregates.
_Avoid_: feedback (alone), comment, testimonial, rating (rating is the numeric part only)

**Indicative Value**:
An estimate of gold content value from weight and the Reference Gold Rate. Guidance only — never a quotation or an Offer. Used for bullion minimum checks and display.
_Avoid_: price, valuation (as binding), appraisal, quote

**Reference Gold Rate**:
The platform’s current indicative gold price per gram per purity, used for display and indicative calculations.
_Avoid_: spot price (alone), market rate (as an authoritative sale price), offer rate

## Gold product language

**Bullion**:
Gold in bar or ingot form, valued primarily by weight and purity rather than workmanship. Subject to a platform minimum Indicative Value.
_Avoid_: bar (alone), ingot (alone) as the Request Type name

**Karat**:
Gold purity in twenty-fourths (for example 24K, 22K, 21K, 18K).
_Avoid_: carat (gem mass), purity (alone when karat is meant)

**Fineness**:
Purity in parts per thousand (for example 999, 916, 875, 750), corresponding to common karats.
_Avoid_: karat (when fineness is meant)

**Making Charges**:
The labour and craftsmanship component of an ornament price, distinct from gold content value.
_Avoid_: fees, premium (alone), workmanship cost (as primary)

## Governance

**Abuse Report**:
A structured complaint about a Request, Offer, Connection, Review, or counterparty, handled by Platform Admins. Reporter identity is not disclosed to the reported party.
_Avoid_: ticket (alone), flag (alone), complaint
