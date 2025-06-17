#import "cv.typ": *

#let cvdata = yaml("cv_zhan.yml")

#set footnote(numbering: "*")

#let uservars = (
    headingfont: (name: "Source Han Serif"),
    bodyfont: (name: "Source Han Serif"),
    fontsize: 10pt, // 10pt, 11pt, 12pt
    linespacing: 8pt,
    showAddress: false, // true/false show address in contact info
    showNumber: true,  // true/false show phone number in contact info
    headingsmallcaps: true
)

// setrules and showrules can be overridden by re-declaring it here
// #let setrules(doc) = {
//      // add custom document style rules here
//
//      doc
// }

#let customrules(doc) = {
    // add custom document style rules here
    set page(
        paper: "us-letter", // a4, us-letter
        numbering: "1 / 1",
        number-align: center, // left, center, right
        margin: 1.25cm, // 1.25cm, 1.87cm, 2.5cm
    )

    doc
}

#let cvinit(doc) = {
    doc = setrules(uservars, doc)
    doc = showrules(uservars, doc)
    doc = customrules(doc)

    doc
}

// each section body can be overridden by re-declaring it here
// ========================================================================== //

#show: doc => cvinit(doc)



#cvheading(cvdata, uservars)
#cveducation(cvdata)
#v(0.2em)

#cvwork(cvdata)
#v(0.2em)
#cvpublications(cvdata)
#v(0.2em)
// #cvaffiliations(cvdata)
#cvprojects(cvdata)
#v(0.2em)
// #cvcertificates(cvdata)

#cvawards(cvdata)
#v(0.2em)

#cvRES(cvdata)
#v(0.2em)

//#cvskills(cvdata)
//#v(0.5em)

// #cvreferences(cvdata)
// #endnote()