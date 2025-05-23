import SwiftUI

struct MetricCardView: View {
    let metric: SustainabilityMetric
    @ObservedObject private var localizer = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: metric.indicatorCode.icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(metric.category.color)
                    .frame(width: 70, height: 70)
                    .background(metric.category.color.opacity(0.15))
                    .clipShape(Circle())

                Text(localizer.localizedString(forKey: "desc_\(metric.indicatorCode.rawValue.lowercased())"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Text(metric.isPositiveIndicator ? "↑" : "↓")
                    .font(.title3)
                    .foregroundColor(metric.category.color)
                    .fontWeight(.black)
            }

            Divider()
                .background(Color(UIColor.systemGray4))

            HStack(alignment: .firstTextBaseline) {
                Text("\(Int(metric.numericValue))")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(metric.category.color)

                Text(metric.indicatorCode.unit)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 2)

                Spacer()

                Text(localizer.localizedString(forKey: metric.category.rawValue.lowercased().replacingOccurrences(of: " ", with: "_")))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(metric.category.color.opacity(0.2))
                    .foregroundColor(metric.category.color)
                    .clipShape(Capsule())
            }

            Text(metric.dailyEquivalent)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.darkGray))
                .padding(.top, 4)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct HeaderView: View {
    let product: ProductType
    @ObservedObject private var localizer = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 240)
                .padding(.top, 20)

            VStack(spacing: 10) {
                Text(localizer.localizedString(forKey: "product_\(product.rawValue.lowercased().replacingOccurrences(of: " ", with: "_") )"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text(localizer.localizedString(forKey: "\(product.categoryKey.lowercased().components(separatedBy: " ")[0])"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color("1976D2"))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0x12 / 255, green: 0xbe / 255, blue: 0x9e / 255),
                    AppTheme.primary.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
        )
        .foregroundColor(.white)

    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct InfoPanel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
            .padding(.horizontal)
    }
}

struct LoadingView: View {
    @ObservedObject private var localizer = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text(localizer.localizedString(forKey: "loading_message"))
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6).opacity(0.8))
        )
        .padding()
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
        .padding()
    }
}

struct BimboSustainabilityMetricsView: View {
    @StateObject private var viewModel: SustainabilityViewModel
    @ObservedObject private var localizer = LocalizationManager.shared

    init(product: ProductType = .gansito) {
        _viewModel = StateObject(wrappedValue: SustainabilityViewModel(product: product))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeaderView(product: viewModel.product)

                InfoPanel(text: localizer.localizedString(forKey: "info_intro"))

                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else if viewModel.metrics.isEmpty {
                    InfoPanel(text: localizer.localizedString(forKey: "info_no_data"))
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.metrics) { metric in
                            MetricCardView(metric: metric)
                        }
                    }
                }

                InfoPanel(text: localizer.localizedString(forKey: "info_source"))
            }
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("F5F7FA"), Color("E4EAF6")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(localizer.localizedString(forKey: "sustainability_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BimboSustainabilityMetricsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BimboSustainabilityMetricsView(product: .gansito)
        }

        NavigationView {
            BimboSustainabilityMetricsView(product: .mantecadas)
        }

        NavigationView {
            BimboSustainabilityMetricsView(product: .takis)
        }
    }
}
