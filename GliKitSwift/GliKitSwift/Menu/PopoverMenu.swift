//
//  PopoverMenu.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹窗菜单按钮信息
open class PopoverMenuItem: NSObject{
    
    ///标题
    public var title: String?
    
    ///按钮图标
    public var icon: UIImage?
    
    public override init(title: String?, icon: UIImage?) {
        super.init()
        self.title = title
        self.icon = icon
    }
}

///弹窗按钮cell
open class GKPopoverMenuCell: UITableViewCell{
    
    ///按钮
    public lazy var button: Button = {
        
        let btn = Button()
        btn.contentHorizontalAlignment = .left
        btn.adjustsImageWhenDisabled = false;
        btn.adjustsImageWhenHighlighted = false
        btn.isUserInteractionEnabled = false;
        btn.backgroundColor = .clear;
        self.contentView.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        return btn
    }()
    
    ///分割线
    public lazy var divider: Divider = {
        
        let divider = Divider(vertical: false)
        self.contentView.addSubview(divider)
        
        divider.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
        }
        
        return divider
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .gray
        self.selectedBackgroundView = UIView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/**
 弹窗菜单代理
 */
@objc public protocol PopoverMenuDelegate: PopoverDelegate{
    
    ///选择某一个
    @objc optional func popoverMenu(_ popoverMenu: PopoverMenu, didSelectAt index: Int)
}

/**
 弹窗菜单 contentInsets 将设成 0
 */
open class PopoverMenu: Popover {

    ///字体颜色
    public var textColor: UIColor = .black

    ///字体
    public var font = UIFont.systemFont(ofSize: 13)

    ///选中背景颜色
    public var selectedBackgroundColor = UIColor(white: 0.95, alpha: 1.0)

    ///图标和按钮的间隔
    public var iconTitleInterval: CGFloat = 0

    ///菜单行高
    public var rowHeight: CGFloat = 30

    ///菜单宽度 会根据按钮标题宽度，按钮图标和 内容边距获取宽度
    public var menuWidth: CGFloat = 0

    /**
     cell 内容边距 default is '(0, 15.0, 0, 15.0)' ，只有left和right生效
     */
    @property(nonatomic, assign) UIEdgeInsets cellContentInsets;

    /**
     分割线颜色 default is 'GKSeparatorColor'
     */
    @property(nonatomic, strong) UIColor *separatorColor;

    /**
     cell 分割线间距 default is '(0, 0, 0, 0)' ，只有left和right生效
     */
    @property(nonatomic, assign) UIEdgeInsets separatorInsets;

    /**
     按钮信息
     */
    @property(nonatomic, strong, nonnull) NSArray<GKPopoverMenuItem*> *menuItems;

    /**
     标题
     */
    @property(nonatomic, copy) NSArray<NSString*> *titles;

    /**
     点击某个按钮回调
     */
    @property(nonatomic, copy, nullable) void(^selectHandler)(NSInteger index);

    /**
     代理
     */
    @property(nonatomic, weak, nullable) id<GKPopoverMenuDelegate> delegate;
    
   - (instancetype)initWithFrame:(CGRect)frame
   {
       self = [super initWithFrame:frame];
       if(self){
           self.contentInsets = UIEdgeInsetsZero;
           _cellContentInsets = UIEdgeInsetsMake(0, 15, 0, 15);
           _textColor = [UIColor blackColor];
           _font = [UIFont systemFontOfSize:13];
           _selectedBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
           _rowHeight = 30;
           _separatorColor = UIColor.gkSeparatorColor;
           _iconTitleInterval = 0.0;
       }
       
       return self;
   }

   - (void)initContentView
   {
       if(!_tableView){
           _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
           _tableView.rowHeight = _rowHeight;
           _tableView.separatorColor = _separatorColor;
           _tableView.dataSource = self;
           _tableView.delegate = self;
           _tableView.backgroundColor = [UIColor clearColor];
           _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
           _tableView.scrollEnabled = NO;
           self.contentView = _tableView;
       }
       _tableView.frame = CGRectMake(0, 0, [self getMenuWidth], _menuItems.count * _rowHeight);
   }

   - (void)reloadData
   {
       if(self.tableView){
           _tableView.frame = CGRectMake(0, 0, [self getMenuWidth], _menuItems.count * _rowHeight);
           [self.tableView reloadData];
           [self redraw];
       }
   }

   ///通过标题获取菜单宽度
   - (CGFloat)getMenuWidth
   {
       if(_menuWidth == 0){
           CGFloat contentWidth = 0;
           for(GKPopoverMenuItem *item in self.menuItems){
               CGSize size = [item.title gkStringSizeWithFont:_font contraintWith:UIScreen.gkScreenWidth];
               contentWidth = MAX(contentWidth, size.width + item.icon.size.width + _iconTitleInterval);
           }
           
           return contentWidth + _cellContentInsets.left + _cellContentInsets.right;
       }else{
           return _menuWidth;
       }
   }

   // MARK: - Property

   - (void)setTextColor:(UIColor *)textColor
   {
       if(![_textColor isEqualToColor:textColor]){
           if(!textColor)
               textColor = [UIColor blackColor];
           _textColor = textColor;
           [self.tableView reloadData];
       }
   }

   - (void)setFont:(UIFont *)font
   {
       if(![_font isEqualToFont:font]){
           if(!font)
               font = [UIFont systemFontOfSize:13];
           _font = font;
           [self.tableView reloadData];
       }
   }

   - (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
   {
       if(![_selectedBackgroundColor isEqualToColor:selectedBackgroundColor]){
           if(!selectedBackgroundColor)
               selectedBackgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
           _selectedBackgroundColor = selectedBackgroundColor;
           [self.tableView reloadData];
       }
   }

   - (void)setSeparatorColor:(UIColor *)separatorColor
   {
       if(![_separatorColor isEqualToColor:separatorColor]){
           if(!separatorColor)
               separatorColor = UIColor.gkSeparatorColor;
           _separatorColor = separatorColor;
           [self.tableView reloadData];
       }
   }

   - (void)setSeparatorInsets:(UIEdgeInsets)separatorInsets
   {
       if(!UIEdgeInsetsEqualToEdgeInsets(_separatorInsets, separatorInsets)){
           _separatorInsets = separatorInsets;
           [self.tableView reloadData];
       }
   }

   - (void)setRowHeight:(CGFloat)rowHeight
   {
       if(_rowHeight != rowHeight){
           _rowHeight = rowHeight;
           [self reloadData];
       }
   }

   - (void)setMenuWidth:(CGFloat)menuWidth
   {
       if(_menuWidth != menuWidth){
           _menuWidth = menuWidth;
           [self reloadData];
       }
   }

   - (void)setIconTitleInterval:(CGFloat)iconTitleInterval
   {
       if(_iconTitleInterval != iconTitleInterval){
           _iconTitleInterval = iconTitleInterval;
           [self reloadData];
       }
   }

   - (void)setCellContentInsets:(UIEdgeInsets)cellContentInsets
   {
       if(!UIEdgeInsetsEqualToEdgeInsets(_cellContentInsets, cellContentInsets)){
           _cellContentInsets = cellContentInsets;
           [self reloadData];
       }
   }

   - (void)setMenuItems:(NSArray<GKPopoverMenuItem *> *)menuItems
   {
       if(_menuItems != menuItems){
           _menuItems = menuItems;
           [self reloadData];
       }
   }

   - (void)setTitles:(NSArray<NSString *> *)titles
   {
       if(titles.count == 0){
           return;
       }
       NSMutableArray *items = [NSMutableArray arrayWithCapacity:titles.count];
       for(NSString *title in titles){
           [items addObject:[GKPopoverMenuItem infoWithTitle:title icon:nil]];
       }
       self.menuItems = items;
   }

   - (NSArray<NSString*>*)titles
   {
       if(_menuItems.count == 0){
           return nil;
       }
       NSMutableArray *titles = [NSMutableArray arrayWithCapacity:_menuItems.count];
       for(GKPopoverMenuItem *item in _menuItems){
           if(item.title == nil){
               [titles addObject:@""];
           }else{
               [titles addObject:item.title];
           }
       }
       return titles;
   }

   #pragma mark- UITableView delegate

   - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
   {
       return _menuItems.count;
   }

   - (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
   {
       static NSString *cellIdentifier = @"cell";
       
       GKPopoverMenuCell *cell = [[GKPopoverMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
       if(cell == nil){
           cell = [[GKPopoverMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
       }
       
       cell.selectedBackgroundView.backgroundColor = _selectedBackgroundColor;
       cell.button.titleLabel.font = _font;
       [cell.button setTitleColor:_textColor forState:UIControlStateNormal];
       cell.button.tintColor = _textColor;
       cell.button.gkLeftLayoutConstraint.constant = _cellContentInsets.left;
       cell.button.gkRightLayoutConstraint.constant = _cellContentInsets.right;
       
       GKPopoverMenuItem *item = [_menuItems objectAtIndex:indexPath.row];
       [cell.button setTitle:item.title forState:UIControlStateNormal];
       [cell.button setImage:item.icon forState:UIControlStateNormal];
       
       cell.divider.hidden = indexPath.row == _menuItems.count - 1;
       cell.divider.backgroundColor = _separatorColor;
       cell.divider.gkLeftLayoutConstraint.constant = _separatorInsets.left;
       cell.divider.gkRightLayoutConstraint.constant = _separatorInsets.right;
       
       cell.button.imagePadding = _iconTitleInterval;
       
       return cell;
   }

   - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
   {
       [cell setSeparatorInset:UIEdgeInsetsZero];
       
       if([cell respondsToSelector:@selector(setLayoutMargins:)]){
           [cell setLayoutMargins:UIEdgeInsetsZero];
       }
   }

   - (void)layoutSubviews
   {
       [super layoutSubviews];
       [self.tableView setSeparatorInset:UIEdgeInsetsZero];
       
       if([self.tableView respondsToSelector:@selector(setLayoutMargins:)]){
           [self.tableView setLayoutMargins:UIEdgeInsetsZero];
       }
   }

   - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
   {
       [tableView deselectRowAtIndexPath:indexPath animated:YES];
       
       if([self.delegate respondsToSelector:@selector(popoverMenu:didSelectAtIndex:)]){
           [self.delegate popoverMenu:self didSelectAtIndex:indexPath.row];
       }
       !self.selectHandler ?: self.selectHandler(indexPath.row);
       [self dismissAnimated:YES];
   }

}
