import json

if __name__ == "__main__":
    with open("coop.json", mode="r") as f:
        schedules = json.load(f)
        for schedule in schedules:
            if -1 not in schedule["weapon_list"]:
                schedule.update({"rare_weapon": None})
        with open("coops.json", mode="w") as w:
            json.dump(schedules, w, indent=2)

if __name__ == "__main__":
    {
        "randomGreen": None,
        "shooterShort": None,
        "shooterFirst": None,
        "shooterPrecision": None,
        "shooterBlaze": None,
        "shooterNormal": None,
        "shooterGravity": None,
        "shooterQuickMiddle": None,
        "shooterExpert": None,
        "shooterHeavy": None,
        "shooterLong": None,
        "shooterBlasterShort": None,
        "shooterBlasterMiddle": None,
        "shooterBlasterLong": None,
        "shooterBlasterLightShort": None,
        "shooterBlasterLight": None,
        "shooterBlasterLightLong": None,
        "shooterTripleQuick": None,
        "shooterTripleMiddle": None,
        "shooterFlash": None,
        "rollerCompact": None,
        "rollerNormal": None,
        "rollerHeavy": None,
        "rollerHunter": None,
        "rollerBrushMini": None,
        "rollerBrushNormal": None,
        "chargerQuick": None,
        "chargerNormal": None,
        "chargerNormalScope": None,
        "chargerLong": None,
        "chargerLongScope": None,
        "chargerLight": None,
        "chargerKeeper": None,
        "slosherStrong": None,
        "slosherDiffusion": None,
        "slosherLauncher": None,
        "slosherBathtub": None,
        "slosherWashtub": None,
        "spinnerQuick": None,
        "spinnerStandard": None,
        "spinnerHyper": None,
        "spinnerDownpour": None,
        "spinnerSerein": None,
        "twinsShort": None,
        "twinsNormal": None,
        "twinsGallon": None,
        "twinsDual": None,
        "twinsStepper": None,
        "umbrellaNormal": None,
        "umbrellaWide": None,
        "umbrellaCompact": None,
        "shooterBlasterBurst": None,
    }
