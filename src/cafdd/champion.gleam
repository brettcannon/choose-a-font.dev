import cafdd/fonts
import lustre/attribute
import lustre/element
import lustre/element/html

pub type Model {
  Model(champion: fonts.Font)
}

pub type Msg

pub fn update(model: Model, _msg: Msg) -> Model {
  model
}

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([attribute.id("winner")], [
    html.a([attribute.href(model.champion.homepage)], [
      html.text(model.champion.family),
    ]),
  ])
}
