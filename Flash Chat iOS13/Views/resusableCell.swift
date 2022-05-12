import UIKit

class resusableCell: UITableViewCell {

    @IBOutlet var meLabel: UILabel!
    @IBOutlet var myView: UIView!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var leftImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myView.layer.cornerRadius = myView.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
