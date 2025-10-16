//
//  AnnouncementParser.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/16.
//

import Foundation
import SWXMLHash

extension Announcement {
    public static func parse(from content: String) -> Announcement? {
        let document: XMLIndexer = XMLHash.config { _ in }.parse(content)
        let root: XMLIndexer = document["announcement"]
        
        let isImportant: Bool = root.element?.attribute(by: "isImportant")?.text == "true"
        guard let author: String = root.element?.attribute(by: "author")?.text,
              let time: String = root.element?.attribute(by: "time")?.text,
              let date: Date = DateFormatters.shared.iso8601Formatter.date(from: time),
              let title: String = root["title"].element?.text else {
            return nil
        }
        
        var contentList: [Announcement.Content] = []
        for child in root["content"].children {
            if let element = child.element {
                switch element.name {
                case "text":
                    if let text = Announcement.Text.parse(from: child) {
                        contentList.append(.text(text))
                    }
                case "link":
                    if let link = Announcement.Link.parse(from: child) {
                        contentList.append(.link(link))
                    }
                case "tip":
                    if let tip = Announcement.Tip.parse(from: child) {
                        contentList.append(.tip(tip))
                    }
                case "h1", "h2", "h3":
                    if let title = Announcement.Title.parse(from: child) {
                        contentList.append(.title(title))
                    }
                default:
                    warn("不支持的元素: \(element.name)")
                    contentList.append(.text(.init(content: "你的启动器版本过低，不支持 \(element.name) 元素的显示。", size: 14, strike: false)))
                }
            }
        }
        return Announcement(
            title: title,
            isImportant: isImportant,
            author: author,
            time: date,
            content: contentList
        )
    }
}

extension Announcement.Text {
    static func parse(from xml: XMLIndexer) -> Announcement.Text? {
        guard let text = xml.element?.text else { return nil }
        let size: CGFloat = CGFloat(Float(xml.element?.attribute(by: "size")?.text ?? "") ?? 14)
        let strike: Bool = xml.element?.attribute(by: "strike")?.text == "true"
        return Announcement.Text(content: text, size: size, strike: strike)
    }
}

extension Announcement.Link {
    static func parse(from xml: XMLIndexer) -> Announcement.Link? {
        let urlString: String = xml.element?.text ?? ""
        let display: String = xml.element?.attribute(by: "display")?.text ?? urlString
        guard let url = URL(string: urlString) else { return nil }
        return Announcement.Link(url: url, display: display)
    }
}

extension Announcement.Tip {
    static func parse(from xml: XMLIndexer) -> Announcement.Tip? {
        guard let color = xml.element?.attribute(by: "color")?.text
        else { return nil }
        let text: String = xml.element?.text ?? ""
        return Announcement.Tip(text: text, color: color)
    }
}

extension Announcement.Title {
    static func parse(from xml: XMLIndexer) -> Announcement.Title? {
        guard let text = xml.element?.text else { return nil }
        let size: CGFloat = switch xml.element?.name {
        case "h1": 20
        case "h2": 18
        case "h3": 16
        default: 14
        }
        
        return Announcement.Title(text: text, size: size)
    }
}
