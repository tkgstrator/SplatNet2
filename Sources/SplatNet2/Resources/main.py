import json

if __name__ == "__main__":
    with open("coop.json", mode="r") as f:
        schedules = json.load(f)
        for schedule in schedules:
            if -1 not in schedule["weapon_list"]:
                schedule.update({"rare_weapon": None})
        with open("coops.json", mode="w") as w:
            json.dump(schedules, w, indent=2)
