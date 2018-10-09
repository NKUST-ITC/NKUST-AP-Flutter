class News{
  String title;
  int weight;
  String image;
  String url;
  String content;

  News({
    this.title,this.weight,this.image,this.url,this.content,
  });

  static News fromJson(Map<String,dynamic> json){
    return News(
      title: json['news_title'],
      weight: json['news_weight'],
      image: json['news_image'],
      url: json['news_url'],
      content: json['news_content'],
    );
  }

  Map<String, dynamic> toJson() => {
    'news_title': title,
    'news_weight': weight,
    'news_image': image,
    'news_url': url,
    'news_content': content,
  };

  static List<News> toList(List<dynamic> jsonArray) {
    List<News> list = [];
    for (var item in (jsonArray ?? [])) list.add(News.fromJson(item));
    return list;
  }
}