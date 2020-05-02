//
//  NumberPickerView.swift
//  Beans
//
//  Created by Jordan Gustafson on 2/15/20.
//  Copyright © 2020 Jordan Gustafson. All rights reserved.
//

import SwiftUI
import Combine

public struct NumberPickerView: View {
    
    let value: Binding<Double>
    let minValue: Double
    let maxValue: Double
    let closeButtonAction: () -> Void
    
    public var body: some View {
        VStack {
            HStack {
                Spacer().frame(maxWidth: .infinity)
                Button(action: {
                    self.closeButtonAction()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.headline)
                        .accentColor(.orange)
                }
            }.padding([.leading, .trailing], 2)
            NumberPickerCollectionViewWrapper(value: value, minValue: minValue, maxValue: maxValue)
                .frame(minWidth: 240, idealWidth: nil, maxWidth: .infinity, minHeight: 96, idealHeight: 96, maxHeight: 96, alignment: .leading)
        }
        .roundedPaddedBackground(paddingInsets: EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
    
    public init(value: Binding<Double>, minValue: Double, maxValue: Double, closeButtonAction: @escaping () -> Void) {
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.closeButtonAction = closeButtonAction
    }
    
}

/// SwiftUI wrapper for NumberPickerCollectionView
struct NumberPickerCollectionViewWrapper: UIViewRepresentable {
    
    let value: Binding<Double>
    let minValue: Double
    let maxValue: Double
    
    init(value: Binding<Double>, minValue: Double, maxValue: Double) {
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    func makeUIView(context: Context) -> NumberPickerCollectionView {
        let numberPickerCollectionView = NumberPickerCollectionView(value: value, minValue: minValue, maxValue: maxValue)
        numberPickerCollectionView.tintColor = UIColor.orange
        return numberPickerCollectionView
    }
    
    func updateUIView(_ uiView: NumberPickerCollectionView, context: Context) {
        uiView.set(value: value.wrappedValue, animated: context.transaction.animation != nil)
    }
    
}

final class NumberPickerCollectionView: UIView {
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private let centerTickView: UIView = UIView()
    
    override var bounds: CGRect {
        didSet {
            generateNumberOfCells()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            centerTickView.backgroundColor = tintColor
            collectionView.reloadData()
        }
    }
    
    let minValue: Double
    let maxValue: Double
    
    private var cells: [Cell] = [] {
        didSet {
            guard cells != oldValue else {
                return
            }
            
            collectionView.reloadData()
        }
    }
    
    private var valueUpdatedClosure: ((Double) -> Void)?
    private var isScrolling: Bool = false
    
    private let cellWidth: CGFloat = 96
    private var paddingCellWidth: CGFloat {
        return collectionView.bounds.width / 2
    }
    
    init(value: Binding<Double>, minValue: Double, maxValue: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 96))
        configureView()
        DispatchQueue.main.async {
            //Need to wait a loop to set the initial values
            self.set(value: value.wrappedValue, animated: false)
            //Set after we are at initial value
            //Don't want to post back until everything is set
            self.valueUpdatedClosure = { value.wrappedValue = $0 }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        backgroundColor = .clear
        
        flowLayout.scrollDirection = .horizontal
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundView = nil
        collectionView.backgroundColor = .clear
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.register(NumberPickerCollectionViewCell.self, forCellWithReuseIdentifier: NumberPickerCollectionViewCell.identifier)
        collectionView.register(NumberPickerEmptyPaddingCollectionCell.self, forCellWithReuseIdentifier: NumberPickerEmptyPaddingCollectionCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        (collectionView as UIScrollView).delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
        
        centerTickView.backgroundColor = tintColor.withAlphaComponent(0.75)
        centerTickView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerTickView)
        centerTickView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        centerTickView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        centerTickView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        centerTickView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        generateNumberOfCells()
    }
    
    func set(value: Double, animated: Bool) {
        guard !isScrolling, value != currentValueFromCollectionView() else {
            return
        }
        
        collectionView.setContentOffset(calculateContentOffset(for: value), animated: animated)
    }
    
    private func generateNumberOfCells() {
        let start = Int(minValue)
        let end = Int(maxValue - 1)
        
        var newCells: [Cell] = [.padding]
        for i in start...end {
            newCells.append(.number(Double(i)))
        }
        newCells.append(.padding)
        cells = newCells
    }
    
    private func calculateContentOffset(for value: Double) -> CGPoint {
        let xOffset = (cellWidth * CGFloat(value - minValue))
        return CGPoint(x: xOffset, y: 0)
    }
    
    private func currentValueFromCollectionView() -> Double {
        return value(for: collectionView.contentOffset)
    }
    
    private func value(for contentOffset: CGPoint) -> Double {
        let raw = ((Double(contentOffset.x) / Double(cellWidth)) + minValue)
        return min(max(minValue, raw), maxValue)
    }
    
}

//MARK: - Cell Models

extension NumberPickerCollectionView {
    
    enum Cell: Equatable {
        case number(Double)
        case padding
    }
    
}

//MARK: - UIScrollViewDelegate

extension NumberPickerCollectionView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isScrolling else {
            return
        }
        
        valueUpdatedClosure?(value(for: scrollView.contentOffset))
    }
    
}

extension NumberPickerCollectionView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else {
            return 0
        }
        
        return cells.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch cells[indexPath.row] {
        case let .number(number):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberPickerCollectionViewCell.identifier, for: indexPath) as? NumberPickerCollectionViewCell else {
                preconditionFailure("CollectionView not configured properly")
            }
            
            cell.tintColor = tintColor
            cell.number = number
            return cell
        case .padding:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberPickerEmptyPaddingCollectionCell.identifier, for: indexPath) as? NumberPickerEmptyPaddingCollectionCell else {
                preconditionFailure("CollectionView not configured properly")
            }
            
            return cell
        }
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension NumberPickerCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch cells[indexPath.row] {
        case .number:
            return CGSize(width: cellWidth, height: 96)
        case .padding:
            return CGSize(width: paddingCellWidth, height: 96)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

//MARK: - NumberPickerCollectionViewCell

final class NumberPickerCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "NumberPickerCollectionViewCellId"
    
    var number: Double? {
        didSet {
            guard let number = number else {
                numberLabel.text = nil
                return
            }
            
            numberLabel.text = String(format: "%.1f", arguments: [number])
        }
    }
    
    override var bounds: CGRect {
        didSet {
            guard bounds.height != oldValue.height else {
                return
            }
            
            layoutTickMarks()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            guard tintColor != oldValue else {
                return
            }
            
            layoutTickMarks()
        }
    }
    
    private let numberLabel = UILabel()
    
    private let numberOfTicks: Int = 10
    private let tallTickToShortTickRatio: CGFloat = 2 / 3
    
    private var tickViews: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        clipsToBounds = false
        
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        
        numberLabel.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(numberLabel)
        numberLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        
        layoutTickMarks()
    }
    
    private func layoutTickMarks() {
        /// Dump all exisiting ticks and start over
        tickViews.forEach { $0.removeFromSuperview() }
        tickViews = []
        
        let tickCenterLineGap = bounds.width / CGFloat(numberOfTicks)

        var previousTickView: UIView?
        for i in 1...(numberOfTicks) {
            let tickView = UIView()
            tickView.backgroundColor = tintColor
            tickView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(tickView)
            tickView.widthAnchor.constraint(equalToConstant: 1).isActive = true
            // If the tick is the first one then full height, otherwise short height
            let height: CGFloat = i == 1 ? bounds.height : (bounds.height * tallTickToShortTickRatio)
            tickView.heightAnchor.constraint(equalToConstant: height).isActive = true
            tickView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            if let previousTickView = previousTickView {
                //If there's a previous tick, pin center to that one's center plus the gap
                tickView.centerXAnchor.constraint(equalTo: previousTickView.centerXAnchor, constant: tickCenterLineGap).isActive = true
            } else {
                //If first view, then pin center to leading edge
                tickView.centerXAnchor.constraint(equalTo: leadingAnchor).isActive = true
            }
            
            previousTickView = tickView
        }
    }
    
}

final class NumberPickerEmptyPaddingCollectionCell: UICollectionViewCell {
    
    static let identifier: String = "NumberPickerEmptyPaddingCollectionCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        contentView.backgroundColor = .clear
    }
    
}

//MARK: - Previews

struct NumberPickerView_Previews: PreviewProvider {
    
    @State static private var value: Double = 0.0
    
    static var previews: some View {
        Group {
            Group {
                NumberPickerView(value: $value, minValue: 0.0, maxValue: 256.0, closeButtonAction: {})
                    .frame(width: 320)
            }
            Group {
                NumberPickerView(value: $value, minValue: 0.0, maxValue: 256.0, closeButtonAction: {})
                    .frame(width: 320)
            }.environment(\.colorScheme, .dark)
        }
    }
    
}

