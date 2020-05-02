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
    
    override var bounds: CGRect {
        didSet {
            calculateNumberOfCells()
        }
    }
    
    let minValue: Double
    let maxValue: Double
    
    private var numberOfCells: Int = 0 {
        didSet {
            guard numberOfCells != oldValue else {
                return
            }
            
            collectionView.reloadData()
        }
    }
    
    private var valueUpdatedClosure: ((Double) -> Void)?
    private var isScrolling: Bool = false
    
    init(value: Binding<Double>, minValue: Double, maxValue: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 96))
        configureView()
        DispatchQueue.main.async {
            //New to wait a loop to set the initial values
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
        
        flowLayout.estimatedItemSize = CGSize(width: 96, height: 96)
        flowLayout.itemSize = CGSize(width: 96, height: 96)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundView = nil
        collectionView.backgroundColor = .clear
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.register(NumberPickerCollectionViewCell.self, forCellWithReuseIdentifier: NumberPickerCollectionViewCell.identifier)
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
        
        calculateNumberOfCells()
    }
    
    func set(value: Double, animated: Bool) {
        guard !isScrolling, value != currentValueFromCollectionView() else {
            return
        }
        
        collectionView.setContentOffset(calculateContentOffset(for: value), animated: animated)
    }
    
    private func calculateNumberOfCells() {
        let newNumberOfCells = Int(ceil(maxValue - minValue))
        let paddingCells = Int(ceil(bounds.width / flowLayout.itemSize.width))
        numberOfCells = newNumberOfCells + paddingCells
    }
    
    private func calculateContentOffset(for value: Double) -> CGPoint {
        let itemWidth = flowLayout.itemSize.width
        let xOffset = itemWidth * CGFloat(value - minValue)
        return CGPoint(x: xOffset, y: 0)
    }
    
    private func currentValueFromCollectionView() -> Double {
        return value(for: collectionView.contentOffset)
    }
    
    private func value(for contentOffset: CGPoint) -> Double {
        let itemWidth = flowLayout.itemSize.width
        let raw = (Double(contentOffset.x) / Double(itemWidth)) + minValue
        return min(max(minValue, raw), maxValue)
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
        
        return numberOfCells
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberPickerCollectionViewCell.identifier, for: indexPath) as? NumberPickerCollectionViewCell else {
            preconditionFailure("CollectionView not configured properly")
        }
        
        cell.tintColor = tintColor
        cell.number = Double(indexPath.row) + minValue
        return cell
    }
    
}

//MARK: - UICollectionViewDelegate

extension NumberPickerCollectionView: UICollectionViewDelegate { }

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
            
            renderTickMarks()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            guard tintColor != oldValue else {
                return
            }
            
            renderTickMarks()
        }
    }
    
    private let stackView = UIStackView()
    private let numberLabel = UILabel()
    
    private let numberOfTicks: Int = 10
    private let tallTickToShortTickRatio: CGFloat = 2 / 3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        contentView.backgroundColor = .clear
        
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .equalCentering
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        numberLabel.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(numberLabel)
        numberLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        
        renderTickMarks()
    }
    
    private func renderTickMarks() {
        /// Dump all exisiting ticks and start over
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        
        /// Loop through the number of ticks (n) plus one
        /// We need n visible ticks, with n visible gaps between them.
        /// We add an addition invisible tick at the end to get the last gap
        for i in 1...(numberOfTicks + 1) {
            let tickView = UIView()
            // If the tick is the is the last tick, then make it clear, otherwise make it the tint color
            tickView.backgroundColor = i != (numberOfTicks + 1) ? tintColor : UIColor.clear
            tickView.translatesAutoresizingMaskIntoConstraints = false
            tickView.widthAnchor.constraint(equalToConstant: 1).isActive = true
            // If the tick is the first one then full height, otherwise short height
            let height: CGFloat = i == 1 ? bounds.height : (bounds.height * tallTickToShortTickRatio)
            tickView.heightAnchor.constraint(equalToConstant: height).isActive = true
            stackView.addArrangedSubview(tickView)
        }
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

