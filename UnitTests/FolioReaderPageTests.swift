//
//  UnitTests.swift
//  UnitTests
//
//  Created by Vinicius Leal on 28/10/2020.
//  Copyright © 2020 FolioReader. All rights reserved.
//

@testable import FolioReaderKit
import XCTest
import WebKit

class HighlightInjectorTests: XCTestCase {
    
    func test_insertHighlights_correctlyInsertsHighlightsWithSmallString() {
        let initialString = "This is a highlight example to perform test."
        let highlight = makeHighlight()
        
        let modifiedString = HighlightInjector.htmlContentWithInsertedHighlights(
            initialString,
            highlights: [highlight])
        
        XCTAssertEqual(modifiedString.numberOfHighlights(), 1)
        XCTAssertNotEqual(initialString, modifiedString)
    }
    
    func test_insertHighlights_correctlyInsertsHighlights() {
        let initialString: String = .htmlString
        let highlights = makeHighlights()
            
        let modifiedString = HighlightInjector.htmlContentWithInsertedHighlights(
                                initialString,
                                highlights: highlights)
        
        XCTAssertEqual(modifiedString.numberOfHighlights(), highlights.count)
        XCTAssertNotEqual(initialString, modifiedString)
    }
    
    func test_generateTag_insertsCorrectTag() {
        let highlight1 = makeHighlight()
        let tag1 = HighlightInjector.generateTag(from: highlight1, style: "any style")
        
        XCTAssertTrue(tag1.contains(highlight1.highlightId))
        XCTAssertTrue(tag1.contains(highlight1.content))
        XCTAssertTrue(tag1.contains("callHighlightURL(this)"))
        
        let highlight2 = makeHighlight("any note")
        let tag2 = HighlightInjector.generateTag(from: highlight2, style: "any style")
        
        XCTAssertTrue(tag2.contains(highlight1.highlightId))
        XCTAssertTrue(tag2.contains(highlight1.content))
        XCTAssertTrue(tag2.contains("callHighlightWithNoteURL(this)"))
    }
    
    func test_generateLocator_producesCorrectLocator() {
        let highlight = makeHighlight()
        let locator = HighlightInjector.generateLocator(from: highlight)
        
        XCTAssertTrue(locator.contains(highlight.content))
        XCTAssertTrue(locator.contains(highlight.contentPre))
        XCTAssertTrue(locator.contains(highlight.contentPost))
    }
    
    private func makeHighlight(_ note: String? = nil) -> Highlight {
        Highlight(bookId: "Writing On Art Robert",
                  content: "highlight example",
                  contentPost: " to perform",
                  contentPre: "is a ",
                  date: Date(),
                  highlightId: "59E713AC-1523-9340-0D47-6BC53EBCD443",
                  page: 4,
                  type: 0,
                  startOffset: 0,
                  endOffset: 51,
                  noteForHighlight: note)
    }
    
    private func makeHighlights() -> [Highlight] {
        [
            Highlight(bookId: "Writing On Art Robert",
                      content: "I served my apprenticeship in art criticism writing letters. This practice began in notes to a distant relative my maternal great aunt living in New York City who, starting in 1968 when I was eighteen, gave me the grand tour of the Manhattan art world. These missives recounting what I had seen and thought were my way of thanking a person who “had everything”  for showing me around. Also, she <i>was </i>everything I was not stylish, moneyed, and worldly.",
                      contentPost: " Indeed, she knew or had known",
                      contentPre: "",
                      date: Date(),
                      highlightId: "59E713AC-1523-9340-0D47-6BC53EBCD443",
                      page: 4,
                      type: 0,
                      startOffset: 0,
                      endOffset: 51,
                      noteForHighlight: nil),
            Highlight(bookId: "Writing On Art Robert",
                      content: "These missives recounting what I had seen and thought were my way of thanking",
                      contentPost: " a person who “had everything”",
                      contentPre: "r of the Manhattan art world. ",
                      date: Date(),
                      highlightId: "E3FC3180-DF84-319E-E5F4-5220F416DBB7",
                      page: 4,
                      type: 0,
                      startOffset: 253,
                      endOffset: 330,
                      noteForHighlight: "Note ..."),
            Highlight(bookId: "Writing On Art Robert",
                      content: "One evening, early in our acquaintance, my great aunt took me downtown to the loft of William Rubin, the then newly named chief curator of the Department of Painting",
                      contentPost: " and Sculpture at М0МА. For up",
                      contentPre: " ",
                      date: Date(),
                      highlightId: "77FED9F0-7AE1-5666-6741-085E732AA89A",
                      page: 4,
                      type: 0,
                      startOffset: 3,
                      endOffset: 168,
                      noteForHighlight: nil)
        ]
    }
}

class FolioReaderPageTests: XCTestCase {

    func test_loadHTML_deliversMessageToWebView() {
        let sut = FolioReaderPage()
        let webViewSpy = WebViewSpy()
        
        sut.webView = webViewSpy
        let htmlString: String = .htmlString
        let baseURL = anyURL()
        
        sut.loadHTMLString(htmlString, baseURL: baseURL)
        
        XCTAssertEqual(webViewSpy.loadedURLs, [baseURL])
        XCTAssertEqual(webViewSpy.loadedStrings, [htmlString])
    }
    
    // MARK: - Helpers
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private class WebViewSpy: FolioReaderWebView {
        private var loaded = [(htmlString: String, baseURL: URL?)]()
        
        var loadedURLs: [URL?] {
            loaded.map { $0.baseURL }
        }
        
        var loadedStrings: [String] {
            loaded.map { $0.htmlString }
        }
        
        convenience init() {
            let container = FolioReaderContainer(withConfig: FolioReaderConfig(), folioReader: FolioReader(), epubPath: "any path")
            self.init(frame: CGRect(x: 0, y: 0, width: 300, height: 300), readerContainer: container)
        }
        
        override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
            loaded.append((string, baseURL))
            return nil
        }
    }
}

private extension Highlight {
    convenience init(
        bookId: String? = nil,
        content: String? = nil,
        contentPost: String? = nil,
        contentPre: String? = nil,
        date: Date? = nil,
        highlightId: String? = nil,
        page: Int = 0,
        type: Int = 0,
        startOffset: Int = -1,
        endOffset: Int = -1,
        noteForHighlight: String? = nil
    ) {
        self.init()
        self.bookId = bookId
        self.content = content
        self.contentPost = contentPost
        self.contentPre = contentPre
        self.date = date
        self.highlightId = highlightId
        self.page = page
        self.type = type
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.noteForHighlight = noteForHighlight
    }
}

private extension String {
    static let htmlString = """
    <!DOCTYPE html>\r\n<html class=\"andada mediaOverlayStyle0 textSizeFour\"xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" xml:lang=\"en-US\" lang=\"en-US\">\r\n<head>\r\n<meta charset=\"utf-8\" />\r\n<title>Writing On Art Robert Storr</title>\r\n<link href=\"css/stylesheet.css\" rel=\"stylesheet\" type=\"text/css\"/>\r\n\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\">\n</head>\r\n<body>\r\n<h2 class=\"chaptertitle1\"><a id=\"page_4\"/><a id=\"page_5\"/>The Accidental Critic</h2>\r\n<p class=\"aut\"><b>by Robert Storr</b></p>\r\n<p class=\"noindent\">I served my apprenticeship in art criticism writing letters. This practice began in notes to a distant relative my maternal great aunt living in New York City who, starting in 1968 when I was eighteen, gave me the grand tour of the Manhattan art world. These missives recounting what I had seen and thought were my way of thanking a person who &#x201C;had everything&#x201D;  for showing me around. Also, she <i>was </i>everything I was not stylish, moneyed, and worldly. Indeed, she knew or had known &#x201C;everyone who was anyone&#x201D;  in painting, sculpture, music, dance, and literature since the 1930s on both sides of the Atlantic and down to Mexico really knew them. And she generously put me in direct touch with people, places, and things I had only read about, beginning with <i>The Autobiography of Alice &#x0412;. Toklas</i> (1933) by Gertrude Stein, which I pulled off the shelf for summer reading when I was a very impressionable sixteen. But why was a copy so near at hand? Because Stein and Toklas were not only among my great aunt&#x2019;s friends, they had been guests in the rooming house run by my widowed paternal grandmother in Olivet, Michigan, during the Great Depression while they were making their trans American promotional tour that caused the <i>Autobiography</i> to become a bestseller and the pair improbable national celebrities in an otherwise self-absorbed, largely anti-modernist, not to mention homophobic country.</p>\r\n<p class=\"indent\">   One evening, early in our acquaintance, my great aunt took me downtown to the loft of William Rubin, the then newly named chief curator of the Department of Painting and Sculpture at &#x041C;0&#x041C;&#x0410;. For uptown people like her, the world below 20th Street was still largely <i>terra incognita.</i> As someone who was for the most part raised in Chicago, all of New York was wondrously strange to me, and in the late 1960s and early l970s, much of it was dark and sinister this was in the era of Charles Bronson&#x2019;s vigilante movies. I&#x2019;d grown up on the unpredictably violent streets of Chicago&#x2019;s South Side, but Manhattan struck me as so much more monolithically menacing.</p>\r\n<p class=\"indent\">   In a whirlwind that evening, for the first time I &#x201C;met&#x201D;  Christo and his wife Jeanne Claude, Frank Stella, Patty and Claes Oldenburg, George Segal, Jasper Johns, and Lee Krasner, who handed me my first high octane drink, took me in tow, and maneuvered me into place when she needed protection from collectors and dealers zeroing in on her in order to get preferential access to paintings by her late husband Jackson Pollock, a stunning example of which hung on the wall. She made no secret of how hurtful the sidelining of her own achievements was, but just as obviously she also <a id=\"page_6\"/>enjoyed toying with suitors for his remaining masterworks. Even so, Krasner&#x2019;s palpable resentment was an early lesson in the sexual politics of art that I would remember.</p>\r\n<p class=\"indent\">Likewise, I owe to my great aunt exposure to Eva Hesse&#x2019;s last show during Hesse&#x2019;s short lifetime (it was at Fischbach Gallery, New York, in April 1970) and a chance to see Henry Geldzahler&#x2019;s controversial landmark survey <i>New York Painting and Sculpture, 1940-1970</i> at the Metropolitan Museum of Art in 1969. Nor have I ever forgotten the Robert Ryman retrospective at the Guggenheim in 1972 that I also saw thanks to her. Nothing in my upbringing or schooling had prepared me for its combination of austerity and sensuality, but the sustained freshness of Ryman&#x2019;s painting had an immediate, profound, and abiding impact. So too did memorable concerts and evenings at the ballet where I was able for the first time to witness high class schmoozing among such luminaries as Edward Gorey, Andy Warhol, Lincoln Kirstein, and his sister Mina Curtiss. I felt like I was the na&#x00EF;ve, impecunious, young provincial in a Balzac novel, much as a I subsequently have on many similar occasions thereafter.</p>\r\n<p class=\"indent\">This episodic education by immersion lasted almost exactly a decade. During the first four years of it, I attended Swarthmore College just outside of Philadelphia where I studied French literature, history, and art, after having been a student in France during the eventful year of 1967-68. At Swarthmore I had two remarkable art history professors but was unable to take any studio courses, though I drew a great deal on my own. During one summer, thanks to a roommate whose Old Left father had taken his family to Mexico during the McCarthy era, I was introduced to the expatriate African American artist Elizabeth Catlett Mora. She in turn introduced me to David Alfaro Siqueiros for whom I worked for several months as an assistant at his studio in Cuernavaca and on his last major public project, the Polyforum Cultural in downtown Mexico City. Just outside of that site, I had a rendezvous with my great aunt who was returning to the place where she had befriended Diego Rivera and Jos&#x00E9; Clemente Orozco in the 1930s but never met Siqueiros. Although her staunchly Republican politics were completely at odds with his and mine she was happy that I was in a position to introduce her to him at long last.</p>\r\n<p class=\"indent\">Philadelphia not only boasted a great encyclopedic museum but also the fabled and at that time still all but shut away Barnes Foundation, which I visited with the same art history professor who also got his classes into the print collection of Lessing Rosenwald in Jenkintown, Pennsylvania, a vast, exquisitely chosen resource that in time became the core of the National Gallery&#x2019;s graphic art holdings from D&#x00FC;rer to Picasso.</p>\r\n<p class=\"indent\">From Philadelphia I moved to Boston and worked in Cambridge, where I made my living as an importer of foreign language and art books. Boston was also rich in museums such as Harvard&#x2019;s Fogg and Busch Reisinger Museums as well as the marvelously eccentric Isabella Stewart Gardner Museum, which I visited regularly and home of the School of the Museum of Fine Arts, where I took drawing courses at night. Eventually, after three years, I returned to Chicago, where I had been raised, and applied to the graduate studio program at the School of the Art Institute of Chicago. There, for the first time, I was able to paint with full concentration. By chance, one of my professors was the Funkmaster Ed Paschke, who also served as Jeff Koons&#x2019;s mentor. I completed my Master degree in 1978 making painterly <a id=\"page_7\"/>realist still lifes and interiors that loosely resembled those of Wayne Thiebaud and Philip Pearlstein without being directly influenced by either. From the Art Institute I went directly to the Skowhegan School of Painting and Sculpture that summer and I struck up a contentious relationship with Peter Saul who, like Paschke, was a contrarian in ways that I was not, yet who was a dissenter from the conventional modernist wisdom of the day, as was I.</p>\r\n<p class=\"indent\">   1980 found me back in Cambridge, after a year living in Holland with my wife to be who had gone to The Hague to study the viola da gamba at the Royal Conservatoire. During that time I had a small studio near the Gemeentemuseum, home of the Slijper collection of works by Mondrian (which I visited at least once a week). Shortly after we returned to Massachusetts, my great aunt died, bringing that source of information about art and that outlet for my thoughts to an end. To fill the gap in the latter respect I accepted the offer to be the Boston correspondent for the Chicago based <i>New Art Examiner,</i> the first time my writing was ever published. But, after two years back in New England, I realized that my wife and I would be sucked into the mire of an art world dominated by conservative taste and compromised by academic politics and dependencies, where, furthermore, my wife had hit the glass ceiling of her musical opportunities.</p>\r\n<p class=\"indent\">   With nothing more to go on than a few savings and a combination of restlessness and chutzpah we moved to New York, and started over from scratch. My wife took a day job selling tickets to concerts at the Metropolitan Museum of Art where in short order she found herself on stage playing as a part of the Waverly Consort. I got a job doing construction. Saturdays were devoted to gallery going, Sundays to museums, and evenings were given over to making and arguing about art over beers and cigarettes. I felt as if I had at last arrived at my destination although I&#x2019;d done so at the twilight of classic New York Bohemian life, just as it was about to vanish into art market speculation and gentrification. Or what Peter Schjeldahl called &#x201C;the sex life of money.&#x201D;</p>\r\n<p class=\"indent\">   A regular reader of Schjeldahl&#x2019;s columns in <i>The Village Voice,</i> I was taken with his winning verbal facility combined with his air of cutting edge expertise. I very much liked his poetry too. But when, during our first summer in New York, he wrote a damning with faint praise review of Philip Guston&#x2019;s retrospective at the Whitney Museum of American Art, I was incensed. I&#x2019;d learned about Guston from a fellow student at the Art Institute of Chicago a city that prided itself on being much more attuned to the grotesque than New York. Thus, fueled by righteous anger and all the chutzpah of a Second City wise guy, I wrote a letter to the editor praising Schjeldahl as a writer but taking him to task as a critic, all without hope that my challenge would see print. It didn&#x2019;t.</p>\r\n<p class=\"indent\">   To my complete surprise, however, I did receive a letter back from Peter explaining that while the <i>Voice</i> didn&#x2019;t publish letters as lengthy as mine and whereas I too was woefully wrong on key matters of substance, to my utter amazement he nevertheless thought that I too was a good writer. He went on to invite me for a drink at One University Place, the legendary barkeeper Mickey Ruskin&#x2019;s last stand.</p>\r\n<p class=\"indent\">Also, to my amazement, when we met, Peter proceeded to offer me the slot of junior critic at the <i>Voice.</i> I declined. I had not come to New York to commit most of my hard won free time to passing judgement on the work of others but to make my <a id=\"page_8\"/>own. Peter was dumbfounded that I would spurn his extraordinary gesture, and we awkwardly parted company, with him expressing his incomprehension and frustration. Yet his irritation did not prevent him from sending a copy of my letter to Elizabeth (Betsy) Baker, his friend and the long standing editor of <i>Art in America, </i>with the recommendation that she take me on for short reviews. Which she did. My true apprenticeship as an art writer began in 1982 with her and her second in command, Joan Simon.</p>\r\n<p class=\"indent\">Why recount all of this as a preface to this volume of my collected essays? Because my path to a &#x201C;career&#x201D;  as a critic was anything but what that concept has come to mean in an ever more professional and scholastic art world. Very little of my learning took place in a classroom. By far the better part was in salons, galleries, museums, special collections, libraries, storage vaults, and over the counter in bookstores where my customers had included the Russian linguist Roman Jakobson, an inspiration for postmodernist theory, the African American historian Lerone Bennett, and the sinister Romanian scholar of mythology and religion, Mircea Eliade, who was an early warning that &#x201C;good ideas&#x201D;  occur to bad men or as the fringe benefits of on the job training of disparate kinds such as art handling and shooting the breeze with artists with whom I worked at routine remodeling jobs. Also, as the by product of a job at the School of the Art Institute&#x2019;s Video Data Bank a pioneer project documenting contemporary art and artists founded by Kate Horsfield and Lyn Blumenthal for which I began as a researcher and ended up conducting interviews (including, among the first, one with Buckminster Fuller) &#x2013; I learned how to talk to creative people about their work, and how not to.</p>\r\n<p class=\"indent\">If I put scare quotes around the word &#x201C;career&#x201D;  it is not to be coy or ironic, but simply because being a critic barely rates as one considering how poorly it pays most of those who embrace the vocation only a tiny handful make their living by writing alone and because the other social and political &#x201C;rewards&#x201D;  here I am being ironic in my choice of words such as invitations for openings, dinners, junkets, etc., soon pall. Moreover, they generally come with suspect strings attached, or at high risk to the liver, the waistline, to friendships, to lovers or spouses, and to one&#x2019;s sense of self.</p>\r\n<p class=\"indent\">Ideally discussion of art that matters and of why it matters is best carried on between people who share the experience of art but value it differently. Absent that common exposure to the work, it is the critic&#x2019;s job to describe what he or she has seen and thought much as I did in letters to my great aunt though it is essential that nuanced descriptions play a part in the back and forth between connoisseurs since, as a rule, comparisons between what one says and the other leaves out shed revealing light on the underpinning of their judgements, not least their blind spots and biases. Furthermore, descriptions constitute a tonic reality check on literary embroidery, theoretical wool spinning, and ideological systems building.</p>\r\n<p class=\"indent\">From my perspective, art criticism is dialogic by definition. I deploy that term as the Russian literary critic Mikhail Bakhtin understood it, but am not seeking to invoke his prestige when I do so. Quite the contrary, I firmly believe that critics must speak for themselves and on their own authority, and so simply want to indicate that there are broader intellectual and methodological considerations at issue even as I stick to my own anecdotal exposition of how I approach art writing and how art <a id=\"page_9\"/>writing chose me. Conversations about art letter writing being a form of conversation, as is criticism are what give that art its meanings, and here my use of the plural is quite deliberate. Because art that is worthy of our attention is intrinsically polyvalent while we as individuals have multiple identities that react differently at different times to different aspects of things in the world around us. Art writing, as I understand and practice it, is about artificial, unnatural dimensions of our shared reality that someone has taken exceptional trouble to make, and the exceptional scrutiny these multiple aspects require on the part of the public, including the critic and his or her interlocutors. The benefit of writing about art is identical to the benefit of looking at it: it tests one&#x2019;s faculties of observation and discernment, along with one&#x2019;s capacity for reverie, and such testing is its own reward. In this context, internal dialogue doubts and disagreements with the self is what prompts art as well as what compels our ever shifting responses to works of art. In such exchanges no one, and no particular facet of one&#x2019;s sensibility or mind, gets the last word. And, on that note, I will end with two of my favorite lines from Ezra Pound&#x2019;s <i>Pisan Cantos </i>along with Eliade&#x2019;s work an instance of something worthwhile created by a detestable man which I cite in part to post notice that, as I see things, political virtue is not necessarily coincident with artistic merit or significance:</p>\r\n<p class=\"noindent\">&#x201C;What thou lovest well remains,<br/>the rest is dross&#x201D;</p>\r\n<p class=\"noindent\">&#x201C;nothing matters but the quality<br/>of the affection&#x2014;<br/>in the end&#x2014;that has carved the trace in the mind<br/><i>dove sta memoria&#x201D;</i></p>\r\n</body>\r\n</html>\r\n
    """
    
    func numberOfHighlights() -> Int {
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: "</highlight>", options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
}
