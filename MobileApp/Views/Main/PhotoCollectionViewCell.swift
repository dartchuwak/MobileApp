import UIKit
import SDWebImage

final class ImageCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCollectionViewCell"
    
     private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private lazy var circleProgressView: CircleProgressView = {
            let progressView = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            progressView.center = imageView.center
            progressView.isHidden = true
            return progressView
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: Photo) {
        guard let url = URL(string: image.sizes.last?.url ?? "") else { return }
        circleProgressView.isHidden = false
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"), options: [], progress: { receivedSize, expectedSize, url in
            DispatchQueue.main.async {
                            self.circleProgressView.progress = CGFloat(receivedSize) / CGFloat(expectedSize)
                        }
            
        }) {(_, _, _, _) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.circleProgressView.isHidden = true
            }
        }
    }
}
