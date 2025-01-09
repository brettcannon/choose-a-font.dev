import cafdd/fonts
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub type Model {
  Model(
    sample: String,
    competitors: List(fonts.Font),
    winners: List(fonts.Font),
  )
}

pub type Winner {
  Font1
  Font2
}

pub type Msg {
  UserSelectedFont(Winner)
  UserPressedKeyDown(String)
}

fn ko(model: Model, winner: Winner) -> Model {
  case model.competitors {
    [player1, player2, ..rest] ->
      case winner {
        Font1 -> next_battle(model, player1, rest)
        Font2 -> next_battle(model, player2, rest)
      }
    _ -> panic
  }
}

fn next_battle(
  model: Model,
  victor: fonts.Font,
  combatants: List(fonts.Font),
) -> Model {
  let winner_count = list.length(model.winners)
  let new_winners = [victor, ..model.winners]

  case combatants {
    [] if winner_count == 0 ->
      Model(..model, competitors: [], winners: [victor])
    [] -> Model(..model, competitors: list.reverse(new_winners), winners: [])
    [lonely] -> {
      Model(
        ..model,
        competitors: [lonely, ..list.reverse(new_winners)],
        winners: [],
      )
    }
    rest -> Model(..model, competitors: rest, winners: new_winners)
  }
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectedFont(font) -> ko(model, font)
    UserPressedKeyDown("ArrowLeft") -> ko(model, Font1)
    UserPressedKeyDown("ArrowRight") -> ko(model, Font2)
    UserPressedKeyDown(_) -> model
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  let assert Ok(font1) = list.first(model.competitors)
  let assert Ok(rest_fonts) = list.rest(model.competitors)
  let assert Ok(font2) = list.first(rest_fonts)

  html.div([attribute.id("battle"), event.on_keydown(UserPressedKeyDown)], [
    html.pre([attribute.style([#("font-family", font1.family)])], [
      html.text(model.sample),
    ]),
    html.pre([attribute.style([#("font-family", font2.family)])], [
      html.text(model.sample),
    ]),
    html.div([attribute.class("bottom-row")], [
      html.button(
        [
          event.on_click(UserSelectedFont(Font1)),
          attribute.title("Click or press the left arrow key"),
        ],
        [element.text("Font 1")],
      ),
    ]),
    html.div([attribute.class("bottom-row")], [
      html.button(
        [
          event.on_click(UserSelectedFont(Font2)),
          attribute.title("Click or press the right arrow key"),
        ],
        [element.text("Font 2")],
      ),
    ]),
  ])
}
