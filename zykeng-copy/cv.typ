#import "utils.typ"

// set rules
#let setrules(uservars, doc) = {
    set text(
        font: uservars.bodyfont,
        size: uservars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: uservars.linespacing
    )

    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}

// show rules
#let showrules(uservars, doc) = {
    // uppercase section headings
    show heading.where(
        level: 2,
    ): it => block(width: 100%)[
        #set align(left)
        #set text(font: uservars.headingfont, size: 1.1em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(-0.65em) #line(length: 100%, stroke: 1.5pt + black) // draw a line
        #v(-0.0em)
    ]

    // name title
    show heading.where(
        level: 1,
    ): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.5em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(2pt)
    ]

    doc
}

// set page layout
#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)

    doc
}

// address
#let addresstext(info, uservars) = {
    if uservars.showAddress {
        block(width: 100%)[
            #info.personal.location.city, #info.personal.location.region, #info.personal.location.country #info.personal.location.postalCode
            #v(-4pt)
        ]
    } else {none}
}

#let contacttext(info, uservars) = block(width: 100%)[
    #let profiles = (
        box(link("mailto:" + info.personal.email)),
        if uservars.showNumber {box(link("tel:" + info.personal.phone))} else {none},
        if info.personal.location != none {
            box(info.personal.location.city)
        } else {},
        if info.personal.url != none {
            box(underline(link(info.personal.url)[#info.personal.url.split("//").at(1)]))
        }
    ).filter(it => it != none) // filter out none elements from the profile array

    #if info.personal.profiles != none and info.personal.profiles.len() > 0 {
        for profile in info.personal.profiles {
            profiles.push(
                box(underline(link(profile.url)[#profile.url.split("//").at(1)]))
            )
        }
    }

    #set text(font: uservars.bodyfont, weight: "medium", size: uservars.fontsize * 1)
    #pad(x: 0em)[
        #profiles.join([#sym.space.en #sym.bar.v #sym.space.en])
    ]
]

#let cvheading(info, uservars) = {
    align(center)[
        = #info.personal.name
        #addresstext(info, uservars)
        #contacttext(info, uservars)
    ]
}

#let cvwork(info, isbreakable: true) = {
    if info.work != none {block[
        == Internship Experience
        #for w in info.work {
            block(width: 100%, breakable: isbreakable)[
                // line 1: company and location
                #if w.url != none [
                    *#link(w.url)[#w.organization]* #h(1fr) *#w.location* \
                ] else [
                    *#w.organization* #h(1fr) *#w.location* \
                ]
            ]
            // create a block layout for each work entry
            let index = 0
            for p in w.positions {
                if index != 0 {v(0.6em)}
                block(width: 100%, breakable: isbreakable, above: 0.6em)[
                    // parse ISO date strings into datetime objects
                    #let start = utils.strpdate(p.startDate)
                    #let end = utils.strpdate(p.endDate)
                    // line 2: position and date range
                    #text(style: "italic")[#p.position] #h(1fr)
                    #start #sym.dash.en #end \
                    // highlights or description
                    #for hi in p.highlights [
                        // - #eval(hi.prefix, mode:"markup")
                        #if hi.url != none [
                            - #eval(hi.prefix, mode:"markup")#underline(link(hi.url)[#hi.short])#eval(hi.suffix, mode:"markup")
                        ] else [
                            - #eval(hi.prefix, mode: "markup")
                        ]
                        // #if hi.url != none [
                        //     #underline(link(hi.url)[#hi.short])
                        // ]
                        // #if hi.suffix != none [
                        //     #eval(hi.suffix, mode: "markup")
                        // ]
                    ]
                ]
                index = index + 1
            }
        }
    ]}
}

#let cveducation(info, isbreakable: true) = {
    if info.education != none {block[
        == Education
        #for edu in info.education {
            let start = utils.strpdate(edu.startDate)
            let end = utils.strpdate(edu.endDate)

            let edu-items = ""
            if edu.area != none {{edu-items = edu-items + "- *Research Areas*: " + edu.area + "\n"}}
            if edu.honors != none {
                if edu.grade != none {
                    edu-items = edu-items + "- *Award*: " + edu.honors.join(", ") + "\n"
                } else {
                    edu-items = edu-items + "- *荣誉*: " + edu.honors.join(", ") + "\n"
                }
            }
            if edu.courses != none {edu-items = edu-items + "- *部分课程*: " + edu.courses.join(", ") + "\n"} else {none}
            if edu.highlights != none {
                for hi in edu.highlights {
                    edu-items = edu-items + "- " + hi + "\n"
                }
                edu-items = edu-items.trim("\n")
            }

            // create a block layout for each education entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: institution and location
                #if edu.url != none [
                    *#link(edu.url)[#edu.institution]* #h(1fr) *#edu.location* \
                ] else [
                    *#edu.institution* #h(1fr) *#edu.location* \
                ]
                // line 2: degree and date 
                #text(style: "italic")[#edu.studyType] #h(1fr)
                #start #sym.dash.en #end \
                #eval(edu-items, mode: "markup")
            ]
        }
    ]}
}

#let cvaffiliations(info, isbreakable: true) = {
    if info.affiliations != none {block[
        == Leadership & Activities
        #for org in info.affiliations {
            // parse ISO date strings into datetime objects
            let start = utils.strpdate(org.startDate)
            let end = utils.strpdate(org.endDate)

            // create a block layout for each affiliation entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: organization and location
                #if org.url != none [
                    *#link(org.url)[#org.organization]* #h(1fr) *#org.location* \
                ] else [
                    *#org.organization* #h(1fr) *#org.location* \
                ]
                // line 2: position and date
                #text(style: "italic")[#org.position] #h(1fr)
                #start #sym.dash.en #end \
                // highlights or description
                #if org.highlights != none {
                    for hi in org.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}

#let cvpublications(info, isbreakable: true) = {
    if info.publications != none {block[
        == 主要成果
        #for pub in info.publications {
            // parse ISO date strings into datetime objects
            // create a block layout for each publication entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: publication title
                #if pub.url != none [
                    #link(pub.url)[#pub.name] \
                    #if pub.info != none [ #eval(pub.info, mode: "markup")]
                    #h(1fr) #if pub.publisher != none [ #eval(pub.publisher, mode: "markup")]
                ] else [
                    #eval(pub.name, mode: "markup") //
                    #if pub.info != none [ #eval(pub.info, mode: "markup")]
                    #h(1fr) #if pub.publisher != none [ #eval(pub.publisher, mode: "markup")]
                ]
            ]
        }
    ]}
}


#let cvprojects(info, isbreakable: true) = {
    if info.projects != none {block[
        == 科研项目
        #for project in info.projects {
            // parse ISO date strings into datetime objects
            
            // create a block layout for each project entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: project name
                
                // line 2: organization and date
                #if project.url != none [
                    *#project.name* \
                    #text(style: "italic")[#underline(link(project.url)[#project.repo])]  #h(1fr)  \
                ] else [
                    *#project.name* #h(1fr)  \
                ]
                // summary or description
                #for hi in project.highlights [
                    #if hi.url != none [
                        - #eval(hi.prefix, mode:"markup")#underline(link(hi.url)[#hi.short])#eval(hi.suffix, mode:"markup")
                    ] else [
                        - #eval(hi.prefix, mode: "markup")
                    ]
                ]
            ]
        }
    ]}
}

#let cvawards(info, isbreakable: true) = {
    if info.awards != none {block[
        == 竞赛奖项
        #for award in info.awards {
            // parse ISO date strings into datetime objects
            
            // create a block layout for each award entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: award title and location
                #if award.url != none [
                    #link(award.url)[#award.title] *#award.rank* #h(1fr)  \
                ] else [
                    #eval(award.title, mode:"markup") *#award.rank* #h(1fr)  \
                ]
                // line 2: issuer and date
                // summary or description
                #if award.highlights != none {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}


#let cvRES(info, isbreakable: true) = {
    if info.awards2 != none {block[
        == 研究兴趣
        #for award in info.awards2 {
            // parse ISO date strings into datetime objects
            
            // create a block layout for each award entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: award title and location
                #if award.url != none [
                    #link(award.url)[#award.title] *#award.rank* #h(1fr)  \
                ] else [
                    *#eval(award.title, mode:"markup")* #award.rank #h(1fr)  \
                ]
                // line 2: issuer and date
                // summary or description
                #if award.highlights != none {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}


#let cvcertificates(info, isbreakable: true) = {
    if info.certificates != none {block[
        == Licenses & Certifications

        #for cert in info.certificates {
            // parse ISO date strings into datetime objects
            let date = utils.strpdate(cert.date)
            // create a block layout for each certificate entry
            block(width: 100%, breakable: isbreakable)[
                // line 1: certificate name
                #if cert.url != none [
                    *#link(cert.url)[#cert.name]* \
                ] else [
                    *#cert.name* \
                ]
                // line 2: issuer and date
                Issued by #text(style: "italic")[#cert.issuer]  #h(1fr) #date \
            ]
        }
    ]}
}


#let cvskills(info, isbreakable: true) = {
    if (info.languages != none) or (info.skills != none) or (info.interests != none) {block(breakable: isbreakable)[
        == 研究兴趣
        #if (info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language])
            }
            - *外语*: #langs.join(", ")
        ]
        #if (info.skills != none) [
            #for group in info.skills [
                //#group.category \ 
                #eval(group.category, mode: "markup") \
                //#eval(group.prefix, mode: "markup")
                //#underline(link(group.url)[#group.short])#eval(group.suffix, mode: "markup")
            ]
        ]
        #if (info.interests != none) [
            - *兴趣*: #info.interests.join(", ")
        ]
    ]}
}

#let cvreferences(info, isbreakable: true) = {
    if info.references != none {block[
        == References
        #for ref in info.references {
            block(width: 100%, breakable: isbreakable)[
                #if ref.url != none [
                    - *#link(ref.url)[#ref.name]*: "#ref.reference"
                ] else [
                    - *#ref.name*: "#ref.reference"
                ]
            ]
        }
    ]} else {}
}

#let endnote() = {
    place(
        bottom + right,
        block[
            #set text(size: 5pt, font: "Consolas", fill: silver)
            \*This document was last updated on #datetime.today().display("[year]-[month]-[day]") using #strike[LaTeX] #link("https://typst.app")[Typst].
        ]
    )
}
