  

struct TrackInfo: Identifiable {
    var id: String
    var name: String
    var imageUrl: String?

    init(id: String, name: String, imageUrl: String?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
}
