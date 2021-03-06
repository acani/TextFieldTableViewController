import UIKit

open class TextFieldTableViewController: UITableViewController, UITextFieldDelegate {
  public let placeholders: [[String]]
  open var texts: [[String]]

  public init(placeholders: [[String]], texts: [[String]]) {
    self.placeholders = placeholders
    self.texts = texts
    super.init(style: .grouped)
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done, target: self, action: #selector(doneAction))
  }

  // MARK: - NSCoding

  required public init?(coder: NSCoder) { fatalError("init(coder:) hasn't been implemented") }

  // MARK: - UIViewController

  override open func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableView.automaticDimension
    let identifier = String(describing: TextFieldTableViewCell.self)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: identifier)
  }

  // MARK: - UITableViewDataSource

  override open func numberOfSections(in tableView: UITableView) -> Int { texts.count }

  override open func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    texts[section].count
  }

  override open func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let identifier = String(describing: TextFieldTableViewCell.self)
    let cell = tableView
      .dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TextFieldTableViewCell
    configure(cell: cell, forRowAt: indexPath)
    configureTextField(cell.textField, forRowAt: indexPath)
    return cell
  }

  open func configure(cell: TextFieldTableViewCell, forRowAt indexPath: IndexPath) {
    // Subclasses override this method
  }

  open func configureTextField(_ textField: UITextField, forRowAt indexPath: IndexPath) {
    textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    textField.autocorrectionType = .no
    textField.clearButtonMode = .whileEditing
    textField.delegate = self
    textField.returnKeyType = !isLastIndexPath(indexPath) ? .next : .done
    textField.placeholder = placeholders[indexPath.section][indexPath.row]
    textField.text = texts[indexPath.section][indexPath.row]
  }

  // MARK: - UITextFieldDelegate

  @objc private func textFieldDidChange(_ textField: UITextField) {
    let indexPath = tableView.indexPath(for: textField)!
    texts[indexPath.section][indexPath.row] = textField.text!
  }

  open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let indexPath = tableView.indexPath(for: textField)!
    var nextIndexPath: IndexPath
    if !isLastRow(indexPath.row, inSection: indexPath.section) {
      nextIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
    } else if !isLastSection(indexPath.section) {
      nextIndexPath = IndexPath(row: 0, section: indexPath.section+1)
    } else {
      doneAction()
      return false
    }
    tableView.textFieldForRow(at: nextIndexPath)!.becomeFirstResponder()
    return false
  }

  // MARK: - Actions

  @objc open func doneAction() {
    // Subclasses override this method
  }

  // MARK: - Helpers

  private func isLastRow(_ row: Int, inSection section: Int) -> Bool {
    row == texts[section].count-1
  }

  private func isLastSection(_ section: Int) -> Bool { section == texts.count-1 }

  private func isLastIndexPath(_ indexPath: IndexPath) -> Bool {
    isLastSection(indexPath.section) && isLastRow(indexPath.row, inSection: indexPath.section)
  }
}
