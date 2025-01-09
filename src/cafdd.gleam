import cafdd/battle
import cafdd/champion
import cafdd/fonts
import cafdd/settings
import gleam/list
import lustre
import lustre/element

type Model {
  SettingsModel(settings.Model)
  BattleModel(battle.Model)
  ChampionModel(champion.Model)
}

pub type Msg {
  SettingsMsg(settings.Msg)
  BattleMsg(battle.Msg)
  ChampionMsg(champion.Msg)
}

fn init(_flags) -> Model {
  SettingsModel(settings.Model(
    sample: "Sample text; feel free to edit...\n\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n1Il|\n0Oo\n>= ->",
  ))
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    SettingsMsg(settings.UserReady) -> {
      let assert SettingsModel(settings_model) = model
      BattleModel(
        battle.Model(
          sample: settings_model.sample,
          competitors: list.shuffle(fonts.fonts),
          winners: [],
        ),
      )
    }
    SettingsMsg(msg) -> {
      let assert SettingsModel(settings_model) = model
      settings.update(settings_model, msg) |> SettingsModel
    }
    BattleMsg(msg) -> {
      let assert BattleModel(battle_model) = model
      let new_model = battle.update(battle_model, msg)

      case new_model {
        battle.Model(winners: [champion], competitors: [], sample: _) ->
          champion.Model(champion) |> ChampionModel
        _ -> BattleModel(new_model)
      }
    }
    ChampionMsg(msg) -> {
      let assert ChampionModel(champion_model) = model
      champion.update(champion_model, msg) |> ChampionModel
    }
  }
}

fn view(model: Model) -> element.Element(Msg) {
  case model {
    SettingsModel(settings_model) ->
      settings_model |> settings.view |> element.map(fn(s) { SettingsMsg(s) })
    BattleModel(battle_model) ->
      battle_model |> battle.view |> element.map(fn(s) { BattleMsg(s) })
    ChampionModel(champion_model) ->
      champion_model |> champion.view |> element.map(fn(s) { ChampionMsg(s) })
  }
}

pub fn main() {
  lustre.simple(init, update, view) |> lustre.start("#app", Nil)
}
