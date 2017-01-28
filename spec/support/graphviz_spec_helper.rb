module GraphvizSpecHelper

  def name_of(s)
    s.gsub(/\A"|"\Z/, '')
  end

  def find_edge(edges, from, to)
    edge = edges.find do |each|
      (name_of(each.node_one) == name_of(from) &&
          name_of(each.node_two) == name_of(to))
    end

    expect(edge).to be_present
    edge
  end

  def expect_label_matches(obj, regex)
    expect(obj['label'].source).to match regex
  end

end
