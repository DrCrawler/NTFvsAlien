///Function that sells whatever object this is to the faction_selling; returns a /datum/export_report if successful
/atom/movable/proc/supply_export(faction_selling)
	var/list/points = get_export_value()
	if(!points)
		return FALSE
	SSpoints.supply_points[faction_selling] = clamp((SSpoints.supply_points[faction_selling]+=points[1]),0,HUMAN_FACTION_MAX_POINTS) //NTF edit. Forcibly caps exports to stop infinite Jims
	SSpoints.dropship_points += points[2]
	return new /datum/export_report(points[1], name, faction_selling)

/mob/living/carbon/human/supply_export(faction_selling)
	if(!can_sell_human_body(src, faction_selling))
		return new /datum/export_report(0, name, faction_selling)
	return ..()

/mob/living/carbon/xenomorph/supply_export(faction_selling)
	. = ..()
	if(!.)
		return FALSE

	var/list/points = get_export_value()
	GLOB.round_statistics.points_from_xenos += points[1]

/**
 * Getter proc for the point value of this object
 *
 * Returns:
 * * A list where the first value is the number of req points and the second number is the number of cas points.
 */
/atom/movable/proc/get_export_value()
	. = list(0,0)

/mob/living/carbon/human/get_export_value()
	switch(job.job_category)
		if(JOB_CAT_ENGINEERING, JOB_CAT_MEDICAL, JOB_CAT_REQUISITIONS, JOB_CAT_ENGINEERINGSOM, JOB_CAT_MEDICALSOM, JOB_CAT_REQUISITIONSSOM)
			. = list(200, 20)
		if(JOB_CAT_MARINE, JOB_CAT_MARINESOM)
			. = list(300, 30)
		if(JOB_CAT_SILICON)
			. = list(800, 80)
		if(JOB_CAT_COMMAND, JOB_CAT_COMMANDSOM)
			. = list(1000, 100)
	return

/mob/living/carbon/xenomorph/get_export_value()
	switch(tier)
		if(XENO_TIER_MINION)
			. = list(15, 5)
		if(XENO_TIER_ZERO)
			. = list(50, 5)
		if(XENO_TIER_ONE)
			. = list(75, 10)
		if(XENO_TIER_TWO)
			. = list(150, 15)
		if(XENO_TIER_THREE)
			. = list(250, 25)
		if(XENO_TIER_FOUR)
			. = list(500, 50)
	return

//I hate it but it's how it was so I'm not touching it further than this
/mob/living/carbon/xenomorph/shrike/get_export_value()
	return list(600, 50)

/obj/item/reagent_containers/food/snacks/req_pizza/get_export_value()
	return list(10, 0)

/// Return TRUE if the relation between the two factions are bad enough that a bounty is on the human_to_sell head
/proc/can_sell_human_body(mob/living/carbon/human/human_to_sell, seller_faction)
	var/to_sell_alignement = GLOB.faction_to_alignement[human_to_sell.faction]
	switch(to_sell_alignement)
		if(ALIGNEMENT_NEUTRAL) //No one hates neutral
			return FALSE
		if(ALIGNEMENT_HOSTILE) // Can always sell an hostile unless you are of the same faction
			if(seller_faction == human_to_sell.faction)
				return FALSE
			return TRUE
		if(ALIGNEMENT_FRIENDLY)
			if(GLOB.faction_to_alignement[seller_faction] == ALIGNEMENT_FRIENDLY)
				return FALSE
			return TRUE
