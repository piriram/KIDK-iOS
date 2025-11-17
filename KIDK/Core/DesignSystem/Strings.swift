//
//  Strings.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation

enum Strings {
    enum Auth {
        static let selectUserType = NSLocalizedString("auth.select_user_type", comment: "")
        static let selectUserTypeSubtitle = NSLocalizedString("auth.select_user_type_subtitle", comment: "")
        static let childButton = NSLocalizedString("auth.child_button", comment: "")
        static let parentButton = NSLocalizedString("auth.parent_button", comment: "")
    }
    
    enum Mission {
        static let title = NSLocalizedString("mission.title", comment: "")
        static let goToKIDKCity = NSLocalizedString("mission.go_to_kidk_city", comment: "")
        static let ongoingSavingMissions = NSLocalizedString("mission.ongoing_saving_missions", comment: "")
        static let setGoalInKIDKCity = NSLocalizedString("mission.set_goal_in_kidk_city", comment: "")
        static let setGoalWithFriends = NSLocalizedString("mission.set_goal_with_friends", comment: "")
        static let whatMissionQuestion = NSLocalizedString("mission.what_mission_question", comment: "")
    }
    
    enum TabBar {
        static let account = NSLocalizedString("tab_bar.account", comment: "")
        static let mission = NSLocalizedString("tab_bar.mission", comment: "")
        static let settings = NSLocalizedString("tab_bar.settings", comment: "")
    }
    
    enum Common {
        static let ok = NSLocalizedString("common.ok", comment: "")
        static let cancel = NSLocalizedString("common.cancel", comment: "")
        static let error = NSLocalizedString("common.error", comment: "")
        static let loading = NSLocalizedString("common.loading", comment: "")
    }
    
    enum Error {
        static let userCreationFailed = NSLocalizedString("error.user_creation_failed", comment: "")
        static let unknownError = NSLocalizedString("error.unknown", comment: "")
    }
    
    enum KIDKCity {
        static let school = NSLocalizedString("kidk_city.school", comment: "")
        static let schoolDescription = NSLocalizedString("kidk_city.school_description", comment: "")
        static let mart = NSLocalizedString("kidk_city.mart", comment: "")
    }
    enum MissionSelection {
        static let title = NSLocalizedString("mission_selection.title", comment: "")
        static let recommendedBadge = NSLocalizedString("mission_selection.recommended_badge", comment: "")
        static let videoMission = NSLocalizedString("mission_selection.video_mission", comment: "")
        static let studyMission = NSLocalizedString("mission_selection.study_mission", comment: "")
        static let quizMission = NSLocalizedString("mission_selection.quiz_mission", comment: "")
        static let previous = NSLocalizedString("mission_selection.previous", comment: "")
        static let customMission = NSLocalizedString("mission_selection.custom_mission", comment: "")
    }
}
