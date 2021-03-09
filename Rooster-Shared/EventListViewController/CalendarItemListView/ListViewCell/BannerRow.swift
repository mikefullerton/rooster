//
//  DayBannerRow.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class BannerRow: AbstractBannerRow {
    public struct Banner {
        let banner: String?
        let headline: String?
    }

    override public class func preferredSize(forContent content: Any?) -> CGSize {
        guard let content = content as? Banner else {
            return CGSize(width: -1, height: -1)
        }

        if content.headline != nil && content.banner != nil {
            return CGSize(width: -1, height: 42)
        } else if content.headline != nil {
            return CGSize(width: -1, height: 30)
        } else if content.banner != nil {
            return CGSize(width: -1, height: 30)
        }

        return self.bannerSize(forBanner: content.banner, headline: content.headline)
    }

    override public func willDisplay(withContent content: Any?) {
        guard let content = content as? Banner else {
            return
        }

        self.setBanner(content.banner, headline: content.headline)
    }
}
