import Foundation

// MARK: - Update Profile Request

struct UpdateProfileRequest: Encodable {
    let name: String
    let birthDate: String?
    let phone: String?
}

// MARK: - Status Update Request

struct StatusUpdateRequest: Encodable {
    let status: String
}

// MARK: - Profile Image Upload Response

struct ProfileImageUploadResponse: Decodable {
    let imageUrl: String
}

// MARK: - API Response Wrappers

typealias ApiResponseUserResponse = ApiResponse<UserResponse>
typealias ApiResponseString = ApiResponse<String>
typealias ApiResponseVoid = ApiResponse<EmptyData>
