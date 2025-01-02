import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub type Font {
  Font(family: String, homepage: String)
}

const fonts: List(Font) = [
  Font(
    "Anonymous Pro",
    "https://www.marksimonson.com/fonts/view/anonymous-pro/",
  ),
  Font("B612 Mono", "https://github.com/polarsys/b612"),
  Font("Fira Code", "https://github.com/tonsky/FiraCode"),
  Font("IBM Plex Mono", "https://www.ibm.com/plex/"),
  Font("Inconsolata", "https://levien.com/type/myfonts/inconsolata.html"),
  Font("JetBrains Mono", "https://www.jetbrains.com/lp/mono/"),
  Font("Noto Sans Mono", "https://notofonts.github.io"),
  Font("Red Hat Mono", "https://github.com/RedHatOfficial/RedHatFont"),
  Font("Roboto Mono", "https://github.com/googlefonts/robotomono"),
  Font("Source Code Pro", "https://adobe-fonts.github.io/source-code-pro/"),
  Font("Ubuntu Sans Mono", "https://design.ubuntu.com/font"),
]

pub type Winner {
  Font1
  Font2
}

pub type Model {
  Model(sample: String, competitors: List(Font), winners: List(Font))
}

pub type Msg {
  UserUpdatedSample(String)
  UserReady
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

fn next_battle(model: Model, victor: Font, combatants: List(Font)) -> Model {
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

pub fn init(_flags) -> Model {
  Model(
    sample: "Sample text; feel free to edit...\n\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n1Il|\n0Oo\n>= ->",
    competitors: [],
    winners: [],
  )
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserUpdatedSample(new_sample) -> Model(..model, sample: new_sample)
    UserReady -> Model(..model, competitors: list.shuffle(fonts))
    UserSelectedFont(font) -> ko(model, font)
    UserPressedKeyDown("ArrowLeft") -> ko(model, Font1)
    UserPressedKeyDown("ArrowRight") -> ko(model, Font2)
    UserPressedKeyDown(_) -> model
  }
}

fn view_options(model: Model) -> element.Element(Msg) {
  html.div([attribute.id("options")], [
    html.h1([], [html.text("Choose a (Coding) Font")]),
    html.p([], [
      html.text(
        "This site tries to help you choose a coding font by pitting "
        <> int.to_string(list.length(fonts))
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

fn view_battle(model: Model) -> element.Element(Msg) {
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

fn view_champion(champion: Font) -> element.Element(Msg) {
  html.div([attribute.id("winner")], [
    html.a([attribute.href(champion.homepage)], [html.text(champion.family)]),
  ])
}

pub fn view(model: Model) -> element.Element(Msg) {
  case model {
    Model(sample: _, winners: [], competitors: []) -> view_options(model)
    Model(sample: _, competitors: [_, ..], winners: _) -> view_battle(model)
    Model(sample: _, competitors: [], winners: [champion]) ->
      view_champion(champion)
    Model(_, [], [_, _, ..]) -> panic
  }
}

pub fn main() {
  lustre.simple(init, update, view) |> lustre.start("#app", Nil)
}
