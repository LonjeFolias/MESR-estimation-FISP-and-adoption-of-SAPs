"""Check package links and optionally preservation against the final uploads.
Usage: python tools/check_package.py [--sources /path/to/original/uploads]
This checks source structure, not Stata execution.
"""
from pathlib import Path
import argparse,re,hashlib,json
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--sources',type=Path);args=p.parse_args()
mapping={
'00_master-dofile(5).do':'00_master-dofile.do',
'001_data_cleaning(5).do':'do-files/01_data_cleaning.do',
'02_expenditure.do':'do-files/02_expenditure.do',
'03_ihsvclimate(1).do':'do-files/03_ihsvclimate.do',
'004_labels(2).do':'do-files/04_labels.do',
'06_selmlog(20261106-082935).do':'do-files/06_selmlog.do',
'07_MESR_main(5).do':'do-files/07_MESR_main.do',
'07_MESR_programs(4).do':'do-files/07_MESR_programs.do'}
def executable(text):
    text=re.sub(r'/\*.*?\*/','',text,flags=re.S)
    return [s.strip() for s in text.splitlines() if s.strip() and not s.lstrip().startswith(('*','//'))]
checks=[]
for old,new in mapping.items():
    path=root/new;assert path.is_file(),new
    if args.sources:
        expected=(args.sources/old).read_text().replace('001_data_cleaning.do','01_data_cleaning.do').replace('004_labels.do','04_labels.do')
        assert executable(expected)==executable(path.read_text()),f'Executable source changed: {new}'
        checks.append(f'Preserved executable source: {new}')
main=(root/'00_master-dofile.do').read_text()
for fn in ['01_data_cleaning.do','07_MESR_main.do','08_export_presentation.do']:
    assert fn in main and (root/'do-files'/fn).is_file(),fn
clean=(root/'do-files/01_data_cleaning.do').read_text()
for fn in ['02_expenditure.do','04_labels.do']:
    assert fn in clean and (root/'do-files'/fn).is_file(),fn
assert '03_`IHSnumber\'climate.do' in clean
assert (root/'do-files/03_ihsvclimate.do').is_file()
assert '07_MESR_programs.do' in (root/'do-files/07_MESR_main.do').read_text()
export=(root/'do-files/08_export_presentation.do').read_text()
for fragment in ['objective1_summary.tex','att_atu_ate_summary.pdf','regime_distribution.pdf','Fig2_outcomes_10_15.png','overlap.png','scalars.tex','export_status.txt','lcolor(red)','base: sandy','base: good','base: North']:
    assert fragment in export,fragment
for forbidden in [r'^\s*mprobit ',r'^\s*mlogit ',r'^\s*bootstrap ',r'^\s*mesr_dmf,']:
    assert not re.search(forbidden,export,re.M),forbidden
assert all(x in export for x in ['eproductivitywinsr','eHDDS','eFCS','mproductivitywinsr','mHDDS','mFCS'])
assert 'syntax [, TEXT(string)]' in export
# A simple structural check catches unmatched code blocks outside comments/strings.
active='\n'.join(executable(export));active=re.sub(r'"[^"\n]*"','""',active)
assert active.count('{')==active.count('}'),'Unbalanced exporter code blocks'
checks+=['Active do-file dependencies resolved','Current Overleaf output names covered','Exporter contains no model/bootstrapping calls','Exporter code blocks balanced']
print('\n'.join(checks))
