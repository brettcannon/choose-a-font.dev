import cafdd/fonts
import gleam/int
import gleam/list
import lustre
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
  UserUpdatedSample(String)
  UserReady
  UserSelectedFont(Winner)
  UserPressedKeyDown(String)
}

fn init(_flags) -> Model {
  Model(
    sample: "Sample text; feel free to edit...\n\n"
      <> "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
      <> "abcdefghijklmnopqrstuvwxyz\n"
      <> "0123456789"
      <> "\n"
      <> "1Il|\n"
      <> "0Oo\n"
      <> ">= ->",
    competitors: [],
    winners: [],
  )
}

fn ko(model: Model, winner: Winner) -> Model {
  let assert [player1, player2, ..rest] = model.competitors

  case winner {
    Font1 -> next_battle(model, player1, rest)
    Font2 -> next_battle(model, player2, rest)
  }
}

fn next_battle(
  model: Model,
  victor: fonts.Font,
  combatants: List(fonts.Font),
) -> Model {
  let winner_count = list.length(model.winners)
  let winners = [victor, ..model.winners]

  case combatants {
    [] if winner_count == 0 ->
      Model(..model, competitors: [], winners: [victor])
    [] -> Model(..model, competitors: list.reverse(winners), winners: [])
    [lonely] -> {
      Model(
        ..model,
        competitors: [lonely, ..list.reverse(winners)],
        winners: [],
      )
    }
    rest -> Model(..model, competitors: rest, winners:)
  }
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserUpdatedSample(sample) -> Model(..model, sample:)
    UserReady -> Model(..model, competitors: fonts.all_fonts)
    UserSelectedFont(font) -> ko(model, font)
    UserPressedKeyDown("ArrowLeft") -> ko(model, Font1)
    UserPressedKeyDown("ArrowRight") -> ko(model, Font2)
    UserPressedKeyDown(_) -> model
  }
}

pub fn view_settings(model: Model) -> element.Element(Msg) {
  html.div([attribute.id("options")], [
    html.h1([], [html.text("Choose a (Coding) Font")]),
    html.p([], [
      html.text(
        "This site tries to help you choose a coding font by pitting "
        <> int.to_string(list.length(fonts.all_fonts))
        <> " fonts against each other in a ",
      ),
      html.a(
        [
          attribute.href(
            "https://en.wikipedia.org/wiki/Bracket_%28tournament%29",
          ),
        ],
        [html.text("bracket (tournament)")],
      ),
      html.text("; the last font standing wins!"),
    ]),
    html.p([], [
      html.text(
        "After you specify what sample text you want to use in each \"battle\" below, you will be presented with two fonts to choose between in each battle. Click the button associated with the font you like the most to select a \"winner\" (or use the left/right arrow keys). Battles will continue until there's a single font that has won every battle it has participated in.",
      ),
    ]),
    html.div([], [
      html.textarea(
        [
          event.on_input(UserUpdatedSample),
          attribute.attribute("spellcheck", "false"),
          attribute.placeholder("Sample text goes here..."),
        ],
        model.sample,
      ),
    ]),
    html.div([], [
      html.button([event.on_click(UserReady)], [element.text("Let's Go!")]),
    ]),
  ])
}

pub fn view_battle(model: Model) -> element.Element(Msg) {
  let assert [font1, font2, ..] = model.competitors

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

pub fn view_champion(champion: fonts.Font) -> element.Element(Msg) {
  html.div([attribute.id("winner")], [
    html.a([attribute.href(champion.homepage)], [html.text(champion.family)]),
  ])
}

fn view(model: Model) -> element.Element(Msg) {
  case model {
    Model(sample: _, competitors: [], winners: []) -> view_settings(model)
    Model(sample: _, competitors: [], winners: [champion]) ->
      view_champion(champion)
    _ -> view_battle(model)
  }
}

pub fn main() {
  lustre.simple(init, update, view) |> lustre.start("#app", Nil)
}
