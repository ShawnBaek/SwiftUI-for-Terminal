/// A view that shows one of two possible children.
public enum ConditionalContent<TrueContent: View, FalseContent: View>: View {
    case trueContent(TrueContent)
    case falseContent(FalseContent)

    public var body: Never { fatalError() }
}
