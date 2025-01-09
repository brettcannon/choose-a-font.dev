import cafdd/fonts
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub type Model {
  Model(sample: String)
}

pub type Msg {
  UserUpdatedSample(String)
  UserReady
}

pub fn update(_model: Model, msg: Msg) -> Model {
  case msg {
    UserUpdatedSample(new_sample) -> Model(sample: new_sample)
    // Transition message
    UserReady -> panic
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([attribute.id("options")], [
    html.h1([], [html.text("Choose a (Coding) Font")]),
    html.p([], [
      html.text(
        "This site tries to help you choose a coding font by pitting "
        <> int.to_string(list.length(fonts.fonts))
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
