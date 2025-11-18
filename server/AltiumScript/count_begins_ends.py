import re

for filename in ['component_placement.pas', 'library_utils.pas', 'project_utils.pas']:
    with open(filename, 'r') as f:
        content = f.read()
    content_no_comments = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
    content_no_comments = re.sub(r'\{[^}]*\}', '', content_no_comments)
    begins = len(re.findall(r'\bbegin\b', content_no_comments, re.IGNORECASE))
    ends = len(re.findall(r'\bend\b', content_no_comments, re.IGNORECASE))
    diff = ends - begins
    status = 'BALANCED' if diff == 0 else f'{diff:+d} ({"need more ends" if diff < 0 else "too many ends"})'
    print(f'{filename:30s} begins={begins:3d}  ends={ends:3d}  {status}')
