# Changes - NG:RP v4.1.18

### Changed

#### Command processing and libraries

- Switched command processing from ZCMD to Pawn.CMD with native alias declarations.
- Removed temporary native substitutions and renamed project helpers to distinguish them from library APIs.
- Reused YSI `Random(min, max)` while preserving exclusive upper limits.

#### Accounts and persistence

- Switched account password and shop PIN hashing to samp_bcrypt with cost 10, replacing Whirlpool in plugin configuration.
- Restored chunked account updates with a 2048-cell query buffer.
- Added optional MySQL `PORT` configuration, defaulting to `3306`.

#### Banking and cash payments

- Centralized bank and ATM transfers while preserving existing fees and transaction rules.
- Applied the same cash payment limits and restrictions to `/pay` and the interaction menu.
- Removed the global bank-vault simulation and its administration commands.
- Final ATM, bank and automatic shop writes now require InnoDB and run synchronously after the MySQL queue drains.

#### Elections

- Replaced duplicate-check queries with one database-enforced ballot insert.

#### Gun licenses

- Limited background checks to one matching criminal record.

#### Law enforcement

- Routed interaction-menu cuff, uncuff, drag, detain and ticket actions through command checks.

#### Map and GPS

- Redesigned `/map` with area columns, distances in meters, nearest active job points and paginated business destinations.

#### Account settings

- Unified toggle menus and commands around saved channel IDs, hiding unfinished chatbox and inactive legacy phone preferences.

#### Job core

- Centralized job definitions and default names with consecutive IDs and catalog-generated menus.
- Centralized job slot changes and activity cleanup, with shared skill thresholds and separate help and skill displays.
- Unified `/join` and the Y shortcut around configured job points and one application dialog.
- Consolidated resignation while retaining owned job slots after VIP expiry.
- Removed empty Taxi and inactive Drugs job placeholders.

#### Fishing and Garbage Jobs

- Moved active Fishing to `gamemodes/job/fishing.pwn` and removed the unused legacy module and fish-slot storage.
- Moved Garbage Job to `gamemodes/includes/jobs/`.

#### Craftsman and Arms Dealer Jobs

- Consolidated Craftsman and Arms Dealer recipes while preserving costs, rewards, unlock requirements and crafting EXP rules.

#### Lawyer, Boxing and Treasure Hunter Jobs

- Centralized Lawyer service acceptance and eligibility checks.
- Consolidated Boxing match setup, results and cleanup in its own module.
- Consolidated Treasure Hunter rewards and sales while preserving item prices.

#### Properties and entrances

- Replaced coordinate scans and the legacy entrance toggle with typed dynamic-area lookup for `/enter`, `/exit` and the shortcut.
- Vehicle sales now transfer existing rows without changing their database IDs.

#### Storage

- Limited personal Storage to cash transfers and on-hand material delivery, removing unused container branches.

#### Spike strips

- Replaced spike-strip pickups with per-driver wheel contact checks.

#### Furniture

- Separated furniture cache reads from placement validation.

#### Messages and legacy resources

- Formatted player and server-wide messages at send sites, removing unused buffers.
- Reused `GetVehicleName` for runtime vehicle names and removed redundant decoding buffers.
- Removed unused tutorial implementations and their legacy GUI resources.

### Fixed

#### Medic

- Fixed stretcher cleanup and session checks so cancelled moves and reused player slots cannot move the wrong patient.
- Placed moved patients in the medic's actual interior and virtual world.
- Fixed EMS list selection and prevented duplicate call acceptance.
- Fixed ambulance identification and patient loading with seat, proximity and dimension checks.
- Unified treatment menu actions with command permissions and payment checks, using the $1,000 heal fee.
- Blocked hospital delivery rewards when group funds are insufficient or no bed is available.

#### Elections

- Kept candidate IDs consecutive and removed the blank first menu row.
- Counted each election without carrying over totals from earlier counts or rounds.
- Rejected stale menus after candidate or voting-status changes.

#### Towing

- Saved impounded personal vehicles under their actual owner without falling through to unregistered-vehicle respawn handling.
- Detached impounded vehicles and cleared towing, entrance and pending crate references before cleanup.
- Saved group impound rewards.

#### Group payroll and budgets

- Queued group budget debits and member bank credits in one SQL statement, rejecting insufficient budgets and recipient overflow.
- Corrected formatted amounts in government budget edit logs.

#### Gun licenses

- Rechecked application cash and required applicants to remain at the City Hall arms point until approval.
- Cancelled pending applications after manual license issue or revocation.
- Applied license expiration consistently in MDC and gun shops.
- Corrected account ID formatting in revocation logs.

#### Law enforcement

- Corrected vehicle-distance checks when detaining suspects and stopped dragging after disconnect, death, vehicle entry or loss of restraint.
- Restored `/backup` Code 2 and Code 3 switching and cleared requests after group changes.
- Saved issued vehicle tickets and confiscated trunk weapons immediately.
- Corrected towed-vehicle registration checks and contradictory empty-trunk messages.
- Stored ticket reasons on the recipient for `/accept ticket`.
- Selected nearby vehicles within the player's world and interior.

#### Group weapons

- Saved locker material stock after deposits and withdrawals, validating exact weapon ownership before deposits.
- Rechecked locker access for weapon use and approval, rejecting expired requests and changes to group or weapon slots.
- Aligned weapon and rank menu rows with configured slots and blocked obsolete weapon-safe dialogs.
- Prevented material and crate quantity overflow in locker transfers.
- Saved legacy locker conversions, preserving stock without positive configured costs and using actual row IDs and existing columns.
- Rechecked transfer-crate leadership and recall cooldowns, blocking duplicate deployment and stale resource selections.
- Preserved weapons that destination lockers cannot accept and corrected `/gunloadcrate` vehicle-name lookup.

#### Crates and facilities

- Loaded crates, facilities and orders by persistent row IDs.
- Credited materials from crates actually consumed and preserved crate stock during vehicle-to-forklift transfers.
- Corrected integer budget payments and refunds, saving delivery proceeds to the receiving group.
- Cancelled actions when their player, vehicle, facility or order became invalid, and blocked stale dialogs from overwriting active orders.
- Validated weapon selections and recalculated production from ready crates and crates still in use.

#### Turfs

- Loaded turfs by database ID and skipped malformed rows without overwriting stored data.
- Preserved complete serialized turf data and ownership settings when saving or resizing.
- Rechecked editor permissions, turf and group bounds, and numeric input before applying changes.
- Excluded non-group owners from group taxes and rewards and prevented arithmetic overflow.

#### Gates

- Loaded gates by database ID and validated IDs and editor selections before changing data.
- Corrected open and closed editor positions and invalidated old timers and callbacks after rebuilds or deletion.
- Reset and saved the complete gate configuration on deletion.
- Saved gate lock changes and restored faction-moderator lock access.
- Enforced world and interior restrictions and preserved facility overrides during commands and object rebuilds.
- Started automatic closing delays after opening movement finishes.
- Applied texture changes immediately with opaque RGB colors.
- Corrected movement fines, including free moves at zero percent.
- Removed passwords from status and confirmation messages.

#### Dynamic doors

- Validated door and faction IDs before array access and fully reset ownership and configuration on deletion.
- Saved owner and group-leader lock changes without truncating SQL updates, door labels or rename logs.
- Corrected movement fines and free moves at zero percent.
- Applied Dedicated Player requirements consistently on entry and exit, enforcing GroupType independently of Allegiance.
- Scoped pickups to their configured interior and blocked entry without configured interior coordinates.

#### Map and GPS

- Validated destination addresses and selections, correcting business and door area lookups.
- Preserved active checkpoints when opening the map and corrected destination arrival tracking.

#### Account settings and channels

- Corrected toggle status displays and retained selection IDs when player roles change while menus are open.
- Applied Global OOC, News, Whispers, Bug Chat and Point Messages preferences consistently to their broadcasts.
- Delivered TV news to every recipient and retained administrator access to whispers.
- Restored RepFam HUD preferences when gang representation changes.

#### Job core

- Synchronized stored names and help IDs with the consecutive job catalog, using default names for missing SQL names or placeholders.
- Removed the invalid Drug Dealer skill entry that read plant data as a player skill.
- Blocked applications to legacy or unimplemented jobs and rechecked location, level and available slots on confirmation.
- Preserved Famed access to the third job slot after reconnecting.
- Cleared obsolete service offers after job changes.
- Validated microshop job changes before charging credits.
- Raised skill boosts to the selected job's actual maximum level.
- Loaded job names and points by database ID, skipping invalid rows without deleting them and retaining backing rows when removing resources.
- Detected recruitment points beneath overlapping areas and scoped their map icons to the configured world and interior.
- Rechecked editor permissions and selections, paginated all job-point slots and escaped job names only when building SQL.
- Corrected Arms Dealer, Shipment Contractor and Drug Smuggler skill displays, including level five above 884 smuggler points.
- Included Treasure Hunter, Garbage and independent Fishing in job help.

#### Garbage Job

- Prevented overlapping loading timers from skipping stops and cancelled loading after leaving the assigned truck.
- Required the assigned truck driver at collection and depot points.
- Enabled all nine existing Garbage routes.
- Cleared runs after cancellation, resignation, death, disconnect or truck respawn without disturbing unrelated freezes or checkpoints.
- Prevented payment and skill overflow.

#### Fishing Job

- Included every unlocked species in catch rolls.
- Enforced the 1,000 lb inventory limit without truncating catches.
- Prevented Double EXP skill overflow and applied VIP boosts to the active Fishing skill field.
- Allowed fishing and sales at exact cooldown deadlines.
- Restricted fishing and sales to eligible players in the normal world.
- Rejected fish sales that overflow item values or player cash.
- Preserved unrelated checkpoints and cleared only owned fish-market checkpoints after arrival, sale or death.
- Displayed current fish weight when frisking players.

#### Pizza Boy Job

- Matched destinations to the house exterior's interior and virtual world, including house slot zero.
- Used a five-meter pickup radius at both Pizza Stack locations and required a driver to collect orders.
- Reported unavailable destinations and cancelled deliveries when the selected house changes or becomes unavailable.
- Rechecked job eligibility and cash limits before paying rewards.
- Preserved unrelated checkpoints when clearing deliveries.

#### Bodyguard Job

- Rechecked seller identity, job, availability and matching proximity, world and interior before completing protection offers.
- Allowed exact-balance vest payments while rejecting recipient cash overflow.
- Cleared complete offers after acceptance, cancellation or seller disconnect.
- Blocked frisking while watching TV or spectating.
- Matched Bodyguard help to the ten-second offer cooldown.

#### Arms Dealer Job

- Matched the MP5 listing to its actual skill requirement.
- Prevented melee offers from inheriting firearm EXP.
- Rechecked dealer eligibility, materials, recipient restrictions and matching proximity, interior and world before crafting.
- Blocked crafted weapon delivery during events and boxing matches.
- Consumed offers once before granting weapons and EXP, clearing them fully on cancellation or dealer disconnect.
- Prevented Arms Dealer skill overflow.

#### Lawyer Job

- Restored `/accept lawyer [player]` parsing and rechecked lawyer identity, eligibility and proximity before payment.
- Allowed exact-balance defense payments while rejecting recipient cash overflow.
- Prevented remote releases and lawyer overrides of administrative jail.
- Applied the lawyer approval exemption at skill level five with 400 points.
- Preserved level-up notifications when Double EXP crosses a skill threshold.
- Cleared lawyer duty after disconnect or job resignation.
- Cleared pending defense and appeal metadata when the lawyer disconnects.
- Ended appeal representation when a court case closes or a new hearing begins.
- Notified the Judicial System once when a defendant accepts an appeal.

#### Boxing Job

- Started both boxers after one shared countdown and granted wins, losses and skill rewards only once.
- Rechecked challenges and interrupted matches safely after disconnect, death or participant state changes.
- Returned boxers to their starting gym and restored health using their actual post-match values.
- Corrected champion loss records after title defenses.
- Applied the advertised VIP fighting-style price, allowing exact-balance payments and free normal-style selection.
- Rechecked training location, menu bounds and business IDs before charging or matching queued boxers.

#### Treasure Hunter Job

- Enabled rewards for new hunters and skills above 9999, including every item and rare tiers at skills 150 and 600.
- Applied detector cooldowns after successful searches and limited searches and sales to their intended world and interior.
- Preserved unrelated checkpoints during treasure scans.
- Fixed sale inventory lookup and chest consumption, rejecting item-value and cash overflow.
- Bound inventory loading to the player session, blocking changes until completion and sizing saves for full integer quantities.

#### Shipment Job

- Bound loading and hijacking timers to the original vehicle and player session.
- Restored pending business orders after cancellation or vehicle loss and refreshed orders already taken by another driver.
- Transferred gas-trailer ownership during hijacking and reset detachment warnings after reattachment.
- Bounded and paginated order lists.
- Required assigned destinations and calculated business shipment distance pay from the actual destination.
- Granted one eligible weapon reward per completed trip and skipped group bonuses when the docks point is missing.

#### Mechanic Job

- Tracked repairs at every skill level and cancelled them when player sessions or vehicles become invalid.
- Bound service offers to their original vehicle and prevented repair completion from releasing restrained players.
- Rechecked tires before paid repairs and allowed exact-balance payments.
- Rejected refills for full tanks and reported the actual fuel added near capacity.
- Restored bicycle engines after mechanic repairs.
- Checked vehicle compatibility before installing mechanic upgrades.

#### Craftsman Job

- Fixed closet placement for empty house slots and logged the correct house coordinates.
- Cancelled first-aid timers on cancellation, death or disconnect and allowed healing to reach full health.
- Stopped cameras after their battery deadline and cleared destroyed RC vehicle IDs.
- Preserved the player's return position when saving during remote camera use.
- Validated bug-sweep targets and required matching proximity, interior and world for crafting and bug sweeps.

#### Houses and property sales

- Corrected optional amount parsing in `/hedit` and `/shophouse`.
- Included house IDs in price-change logs.
- Prevented sales from overwriting occupied buyer house slots and saved house or vehicle payments atomically with ownership transfers.
- Corrected invalid target indexes when cancelling contracts.
- Fixed repeated group invitation acceptance by player slot zero.

#### Property entrances

- Validated area types, property IDs and area-list capacity while preserving entrance priority in overlapping areas.
- Scoped business and garage entrances to their world and interior and blocked entry without configured interior coordinates.
- Retained vehicle interior access without a selected property and preserved the Casino entry level restriction.
- Excluded property metadata from furniture-door interactions.
- Removed obsolete house, door and garage entrance resources on deletion, rehash or empty-row reload.
- Rebuilt house entrance resources after interior world changes.

#### Businesses

- Loaded businesses by persistent ID and rejected invalid IDs before editing.
- Restored saved business profits after restart.
- Saved business locks and custom interior and exterior changes.
- Saved all six business rank salaries.
- Saved each gas pump's fuel and capacity from its own slot.
- Preserved long business sale descriptions when saving.
- Confirmed business saves only after the database responds.
- Preserved fractional dealership slot 5 X coordinates.
- Corrected gas-pump deletion log arguments.
- Matched item-list loop bounds to their string tables.
- Removed pickups, areas, pumps and linked vehicles on deletion so deleted resources do not return after reload.
- Cleared deleted business ownership and online or offline employee memberships.
- Blocked business deletion during refueling, deliveries or interior use.

#### Command help

- Bounded help loading and result lists and invalidated stale selections after database reloads.
- Corrected category navigation and group, business and VIP filtering.

#### Furniture

- Aligned purchase rows with selected models, validating catalog entries and limiting loads to 1,000 items.
- Kept the current catalog available until refresh completes and removed stale entries on reload.
- Rejected outdated quotes and rechecked house access and purchase eligibility before committing placement and payment together.
- Released temporary resources after purchase failures and stopped material setup if object creation fails.
- Read placement fields directly from MySQL cache and marked furniture loaded only after query completion and object creation.
- Prevented duplicate placement keys from creating duplicate objects without blocking later valid rows.
- Prevented concurrent duplicate loads and rejected results from obsolete house or replacement requests.
- Allowed stalled or partial loads to retry on later visits while preserving existing objects.

#### Accounts, maintenance and timers

- Prevented duplicate player updates from advancing cooldowns and spawn timeouts twice per second.
- Fixed heartbeat early exits that skipped later players.
- Preserved escaped account text beyond the old save limit.
- Confirmed account saves only after every update chunk completed.
- Cancelled maintenance shutdown on save failure, waiting for pending writes and saving connected accounts before closing MySQL.
- Initialized required registration fields for strict SQL mode.
- Corrected the account ID used for shop PIN lookup.
- Released stalled credential requests after 30 seconds without SQL comment metadata.

#### Vehicle lock picking

- Cancelled lock picking after vehicle owner or slot invalidation and corrected numeric account IDs in trunk logs.

#### Database and geolocation

- Allowed empty-slot seeds to restart after interrupted imports in the same SQL connection.
- Restored country lookup in registration notifications using populated IPv4 data.
- Initialized missing SQLite audit, chat and connection tables at startup.
- Preserved long audit and chat messages with at most two transactional SQLite writes.

#### Banking, cash payments and Storage

- Committed both sides of cash, bank and ATM transfers together.
- Included ATM fees when checking available transfer funds.
- Updated online bank balances only after committed transfers.
- Applied cash-payment cooldowns only on success and removed duplicate account saves.
- Prevented material overflow and preserved packages and checkpoints when Storage updates fail.
- Required the configured delivery world and interior before granting materials or drugs.

#### Staff bans

- Committed ban history and account restrictions together, removing privileges consistently for online and offline staff.
- Enforced staff-ban expiry without restoring previous ranks.
- Blocked staff appointments during active bans.
- Limited online staff-ban listings to active records.
- Prevented expiry timestamp overflow and kept dates consistent across records, messages and logs.

#### Microshop and automatic shop delivery

- Committed phone changes and credit charges together, rejecting stale, repeated or invalid purchase selections.
- Cleared obsolete phone-number reservations.
- Preserved full microshop prices and sales counters during serialization.
- Removed queries against nonexistent `order_delivery_status`.
- Limited automatic shop polling to one pending operation per player.
- Committed vouchers, credit changes and order status as one database operation.

#### Spike strips

- Punctured only tires whose paths intersect the rotated strip, applying correct motorcycle damage bits while retaining Quad behavior.
- Restricted strip objects and driver puncture checks to the deployment world and interior, including zero-axis positions.
- Cleared objects and metadata on deletion or group disbanding and released slots after object-creation failure.

#### Payphones

- Fixed the stray character that prevented compilation.
- Loaded phones by persistent IDs and actual locations, mapping directory selections to validated dialing slots.
- Preserved directory text during area-code lookup and matched incoming calls by the correct number and area.
- Tracked physical terminal users separately from callers, releasing ownership and controls when calls end or players leave.
- Preserved call links during SMS and blocked edits or reloads while terminals are in use.
- Scoped phone writes to the intended row and updated world objects only after committed data was read back.

#### Poker

- Ranked the best five of seven cards with complete kicker and tie comparisons.
- Corrected dealer and blind rotation across empty seats and heads-up hands.
- Completed betting rounds after all required actions, retaining short-blind all-ins at their actual contributions and removing unnecessary blind calls.
- Split main and side pots by contributions and distributed tied-pot remainders in seat order after the dealer.
- Returned unused chips without subtracting them from the pot and settled dealt hands before forced table closure.

#### Gangtags

- Loaded gangtags through R41 cache outputs by persistent ID and mapped dialogs to database IDs.
- Cleared stale reload resources and serialized writes per tag, updating objects only after committed data was read back.

#### Libraries and mapping

- Corrected boolean contracts in `mSelection.inc` and `callbacks.inc`, propagating matching flag and animation types through project calls.
- Corrected the writable format destination in `easyDialog.inc`.
- Applied prison sign text through Streamer to dynamic objects in `Server.pwn`.
- Passed carrier mapping distance as `streamdistance` instead of `worldid` in `Server.pwn`.
- Resolved missing vehicle model-list warnings during isolated startup.

### Performance

- Skipped repeated crate attachments and facility-label updates when their visible state has not changed.
- Updated only changed radar turfs and removed startup writes and duplicate save queries.
- Limited nearby gate scans to active objects and used nearby streamer areas for door lock and password commands.
- Loaded dynamic door backing rows in one query by SQL ID.
- Resolved Y-key recruitment through dynamic-area metadata instead of scanning every job slot, removing unused application arrays.
- Built job-point SQL with one format operation and removed redundant saves on editor exit.
- Consolidated repeated catch branches into one catch table and processing path.
- Replaced countdown timer chains with heartbeat deadlines and set delivery checkpoints once.
- Removed unrelated server configuration writes from delivery rewards.
- Replaced Bodyguard cooldown timer chains with timestamp comparisons.
- Updated the single Boxing match once per heartbeat, removing per-player countdown storage.
- Reused one loading countdown timer and replaced travel countdown timers with deadlines.
- Resolved dropoff points from assigned routes instead of scanning every destination.
- Removed vehicle-pool scans when offering repairs and reused nitrous component and vehicle lookups.
- Replaced entry-check and self-refill cooldown timers with state callbacks and timestamps.
- Removed per-player RC camera polling from the periodic update timer.
- Appended SQL fields without reformatting existing query text and loaded item prices once per row.
- Skipped resource rebuilds for edits that do not change displayed resources.
- Reduced repeated formatting and string scans when building account-save queries.
- Loaded houses directly from the bulk query instead of querying every slot again.
- Packed static string lookup tables and unpacked values at read sites.
- Reused the read-only GeoIP connection and SQLite log journal while retaining synchronous log commits.

### Security

- Bound confirmations to the originating session and round, rechecking voter eligibility and candidate bounds at voting time.
- Locked candidate edits during voting or counting and rejected dialog-row or color-code injection in names.
- Required authorized drivers and empty target vehicles in the same world and interior, rejecting invalid or overflowing rewards.
- Rechecked leadership and nation on confirmation, binding dialogs to their original group and valid rank and amount ranges.
- Rejected application results from old sessions or superseded requests and validated recipients before player-data access.
- Rejected stale drag, tackle-cuff, tazer recharge and backup callbacks after slot reuse.
- Validated player, vehicle and group indexes and required matching worlds and interiors for restraints and confiscation.
- Rechecked door identity and proximity for password responses and rejected stale ownership callbacks after session or door changes.
- Removed passwords from staff status output and audit logs.
- Bound pending offers to their original player sessions and blocked stale saves after unverifiable property-sale results.
- Prevented mechanic service payments from overflowing recipient cash.
- Rejected out-of-turn or repeated bets and blocked buy-ins and seat reuse during unfinished hands.
- Prevented delayed exit cleanup from affecting a new session or table.
- Bound payment and transfer confirmations to the selected account and connection, preventing stale recipients and duplicate transfers.
- Rejected invalid or overflowing amounts and enforced payment proximity, interior and world without the TV bypass.
- Redacted account-save and credential queries, connection identifiers and credential-reset arguments from errors and logs.
- Rejected missing login records and non-bcrypt hashes without a legacy fallback.
- Bound credential callbacks to the original session, account and request and rejected stale player-query results after slot reuse.
- Removed plaintext password storage in `pLastPass` and stopped echoing changed passwords and PINs.
- Validated player IDs, restricted table names to an allowlist and escaped SQLite values.
- Removed full-query output from `DBLog` and `ChatDBLog`.
- Validated house, placement-slot and texture indexes before array access.
- Prevented replayed deliveries and rejected invalid quantities, overflow and mismatched session or account state before fulfillment.
- Rejected stale payphone and gangtag write completions using resource revisions and requester identity.
- Validated gangtag IDs, text and font bounds and checked spray and cleaning timer ownership before mutation.
